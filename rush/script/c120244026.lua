local cm,m=GetID()
cm.name="乌贼合之众"
function cm.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.costfilter(c,e,tp)
	return not c:IsPublic() and RD.IsDefense(c,0)
end
function cm.spfilter(c,e,tp)
	return RD.IsDefense(c,0) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEDOWN_DEFENSE)
end
function cm.max(e,tp,eg,ep,ev,re,r,rp)
	local ct1=RD.GetMZoneCount(tp,2)
	local ct2=Duel.GetMatchingGroupCount(cm.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	return math.min(ct1,ct2)
end
cm.cost=RD.CostShowHand(cm.costfilter,1,cm.max,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ct=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,ct,ct,nil,e,POS_FACEDOWN_DEFENSE)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotSummonEffect(e,aux.Stringid(m,1),cm.sumlimit,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateCannotSetMonsterEffect(e,aux.Stringid(m,2),cm.setlimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLevelBelow(9)
end
function cm.setlimit(e,c)
	return c:IsLocation(LOCATION_HAND)
end