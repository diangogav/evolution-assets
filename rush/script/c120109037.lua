local cm,m=GetID()
cm.name="虚空噬骸兵·神威镇魂鹰巨人"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureThree(c,aux.Stringid(m,0))
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsSummonTurn(c) and c:IsSummonType(SUMMON_VALUE_SELF)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,5,5)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
	local sg=mg:GetMaxGroup(Card.GetLevel)
	if sg:GetCount()>0 and Duel.Destroy(sg,REASON_EFFECT)~=0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local dam=g:GetSum(Card.GetAttack)
		RD.CanDamage(aux.Stringid(m,2),tp,dam,true)
	end
end