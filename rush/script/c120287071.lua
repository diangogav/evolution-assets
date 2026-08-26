local cm,m=GetID()
cm.name="平流层军锤·雷神锤"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureZero(c,aux.Stringid(m,0),cm.sumcon)
	--Level Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumcon(c,e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
--Level Up
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
cm.cost1=RD.CostSendOnFieldToGrave(Card.IsAbleToGraveAsCost,1,1,true)
cm.cost2=RD.CostSendDeckTopToGrave(2)
cm.cost=RD.CostChoose(aux.Stringid(m,3),cm.cost1,aux.Stringid(m,4),cm.cost2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,2),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachLevel(e,g:GetFirst(),4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end