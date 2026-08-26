local cm,m=GetID()
cm.name="混合驱动螺丝起子龙"
function cm.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.costfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.costcheck(g,e,tp)
	return g:FilterCount(Card.IsRace,nil,RACE_DRAGON)==2 and g:FilterCount(Card.IsRace,nil,RACE_MACHINE)==2
end
cm.cost=RD.CostSendGraveSubToDeckBottom(cm.costfilter,cm.costcheck,4,4)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
			local sumlimit=function(e,c)
				return RD.IsSameOriginalCode(c,tc)
			end
			RD.CreateCannotSummonEffect(e,aux.Stringid(m,1),sumlimit,tp,1,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			RD.CreateCannotFaceupSpecialSummonEffect(e,aux.Stringid(m,2),sumlimit,tp,1,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
	end)
end