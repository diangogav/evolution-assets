local cm,m=GetID()
local list={120196050,120253051}
cm.name="念力装备返始"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsCode(list[1],list[2]) and c:IsAbleToDeck()
end
function cm.thfilter(c)
	return ((c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PSYCHO)) or c:IsCode(list[1],list[2])) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,2) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			Duel.BreakEffect()
			if RD.SendToDeckTopOrBottom(g,e,tp,REASON_EFFECT,aux.Stringid(m,2),aux.Stringid(m,3))~=0 then
				RD.CanSelectAndDoAction(aux.Stringid(m,4),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
					RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
				end)
			end
		end)
	end
end