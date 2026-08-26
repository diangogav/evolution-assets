local cm,m=GetID()
cm.name="天之招来"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.thfilter(c)
	return c:IsLevel(10) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	RD.TargetDiscardDeck(tp,3)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.DiscardDeck()~=0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end