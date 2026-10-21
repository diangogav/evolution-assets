local cm,m=GetID()
cm.name="迫击炮的石像"
function cm.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_ROCK)
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
function cm.posfilter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP_DEFENSE)~=0 then
		local filter=RD.Filter(cm.posfilter,e,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,2,nil,function(g)
			RD.ChangePosition(g,e,tp,REASON_EFFECT)
		end)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateHintEffect(e,aux.Stringid(m,2),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not c:IsAttribute(ATTRIBUTE_EARTH)
end