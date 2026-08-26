local cm,m=GetID()
cm.name="健康斗士·娑提"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddHealthySummonProcedure(c,aux.Stringid(m,0),1000)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.spfilter(c,e,tp)
	return RD.IsDefenseBelow(c,1300) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PYRO) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
cm.cost=RD.CostSendDeckTopToGrave(2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(cm.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,POS_FACEUP_DEFENSE)~=0 then
		local filter=RD.Filter(cm.posfilter,e,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_POSITION,filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
			Duel.BreakEffect()
			RD.ChangePosition(g,e,tp,REASON_EFFECT)
		end)
	end
end