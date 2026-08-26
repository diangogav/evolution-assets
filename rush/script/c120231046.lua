local cm,m=GetID()
cm.name="最终化凤凰"
function cm.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.costfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.spfilter(c,e,tp)
	return c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PYRO) and c:IsLevelAbove(1)
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.costcheck(g,e,tp)
	local cg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local lv=cg:GetSum(Card.GetLevel,nil)
	local sg=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_GRAVE,0,g,e,tp)
	return sg:CheckSubGroup(cm.check,1,2,lv,tp)
end
function cm.check(g,lv,tp)
	return (g:GetCount()==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
		and g:GetSum(Card.GetLevel,nil)==lv
		and Duel.GetMZoneCount(tp)>=g:GetCount()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,2,nil)
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,4,4)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local lv=g:GetSum(Card.GetLevel,nil)
	local sg=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return sg:CheckSubGroup(cm.check,1,2,lv,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local lv=g:GetSum(Card.GetLevel,nil)
	local check=RD.Check(cm.check,lv,tp)
	RD.SelectGroupAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),check,tp,LOCATION_GRAVE,0,1,2,nil,e,POS_FACEUP)
end