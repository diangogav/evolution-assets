local cm,m=GetID()
cm.name="高峰窥探魔术师"
function cm.initial_effect(c)
	--Confirm Card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Confirm Card
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then
		Duel.ConfirmDecktop(tp,2)
		Duel.ConfirmDecktop(1-tp,2)
		Duel.BreakEffect()
		Duel.SortDecktop(tp,tp,2)
		Duel.SortDecktop(1-tp,1-tp,2)
	end
end