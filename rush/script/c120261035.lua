local cm,m=GetID()
cm.name="龙类拆除员"
function cm.initial_effect(c)
	--Confirm
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Confirm
function cm.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and RD.IsCanChangePosition(c,e,tp,REASON_COST)
end
function cm.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
cm.cost=RD.CostChangePosition(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_SZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_FACEDOWN,cm.filter,tp,0,LOCATION_SZONE,1,1,nil,function(g)
		Duel.ConfirmCards(tp,g)
		if g:GetFirst():IsType(TYPE_TRAP) then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end)
end