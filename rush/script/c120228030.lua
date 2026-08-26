local cm,m=GetID()
cm.name="暗黑的炽天使"
function cm.initial_effect(c)
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
--Position
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK)
end
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(8) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
		and (not c:IsPosition(POS_FACEUP_ATTACK) or c:IsCanTurnSet())
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
cm.cost=RD.CostPayLP(500)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		local pos=POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			pos=POS_FACEDOWN_DEFENSE
		elseif not tc:IsCanTurnSet() then
			pos=POS_FACEUP_ATTACK
		end
		pos=Duel.SelectPosition(tp,tc,pos)
		RD.ChangePosition(tc,e,tp,REASON_EFFECT,pos)
	end)
end