local cm,m=GetID()
cm.name="祭殿的归还者"
function cm.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.spfilter(c,e,tp)
	return (cm.spfilter1(c) or cm.spfilter2(c)) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.spfilter1(c)
	return c:IsType(TYPE_EFFECT) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_WARRIOR) and RD.IsDefense(c,2100)
end
function cm.spfilter2(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(7) and RD.IsDefense(c,2100)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
end