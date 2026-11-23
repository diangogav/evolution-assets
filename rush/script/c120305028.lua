local cm,m=GetID()
cm.name="队长背号39 球儿皇 霍姆普雷特V"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddFieldToGraveSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter,LOCATION_MZONE,1)
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
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsFaceup() and c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsAbleToGraveAsCost()
end
--Destroy
function cm.costfilter(c)
	return c:IsLevel(8) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler())
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end)
end