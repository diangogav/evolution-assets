local cm,m=GetID()
cm.name="狱火帝皇"
function cm.initial_effect(c)
	--Cannot Special Summon
	RD.CannotSpecialSummon(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
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
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.max(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cm.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return math.min(ct,5)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsAdvanceSummonTurn(e:GetHandler())
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,cm.max,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,e:GetLabel(),0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end