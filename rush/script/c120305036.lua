local cm,m=GetID()
local list={120305036,120196048}
cm.name="选手生还"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return (c:IsRace(RACE_WARRIOR) or c:IsType(TYPE_FIELD)) and c:IsAbleToGraveAsCost()
end
function cm.thfilter1(c)
	return c:IsAbleToHand()
end
function cm.thfilter2(c)
	return c:IsLevel(4,8) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function cm.exfilter(c)
	return c:IsCode(list[2])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=RD.SendDeckTopToGraveAndSelect(tp,3,HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter1),1,1)
	if sg:GetCount()>0 then
		Duel.BreakEffect()
		if RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
			and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
				Duel.BreakEffect()
				RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
			end)
		end
	end
end