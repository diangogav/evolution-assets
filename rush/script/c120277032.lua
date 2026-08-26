local cm,m=GetID()
cm.name="魔力动物射手"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
--Position
function cm.filter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv-1)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(RD.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(RD.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,RD.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local c=e:GetHandler()
		if RD.ChangePosition(g,e,tp,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			local filter=RD.Filter(cm.filter,c:GetLevel())
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end)
		end
	end)
end