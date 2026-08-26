local cm,m=GetID()
local list={120130001}
cm.name="龙队后卫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.confilter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.posfilter(c,e,tp)
	if c:IsControler(tp) then
		return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCode(list[1]) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
	else
		return c:IsAttackPos() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
	end
end
function cm.check(g)
	return g:GetClassCount(Card.GetControler)==2
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,2,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectGroupAndDoAction(HINTMSG_POSCHANGE,filter,cm.check,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil,function(g)
		RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
	end)
end