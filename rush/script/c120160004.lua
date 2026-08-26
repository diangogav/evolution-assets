local cm,m=GetID()
cm.name="念力的埋葬"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
cm.cost=RD.CostPayLP(1000)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	RD.TargetDiscardDeck(tp,2)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.DiscardDeck()
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==3 then
		RD.CanDiscardDeck(aux.Stringid(m,1),tp,1)
	end
end