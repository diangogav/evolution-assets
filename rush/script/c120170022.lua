local cm,m=GetID()
cm.name="魔仙斗 霭朱雀"
function cm.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.costfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.spfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsRace(RACE_WARRIOR) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.costcheck(g,e,tp)
	return g:GetClassCount(Card.GetLinkCode,nil)==g:GetCount()
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,g,e,tp)
end
cm.cost=RD.CostSendGraveSubToDeckBottom(cm.costfilter,cm.costcheck,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
end