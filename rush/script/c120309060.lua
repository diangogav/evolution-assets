local cm,m=GetID()
local list={120309060}
cm.name="大传说的派对"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fake Legend
	RD.EnableFakeLegend(c,LOCATION_HAND+LOCATION_GRAVE)
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
function cm.costfilter(c,e,tp)
	return RD.IsLegendCard(c) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,c,e,tp)
end
function cm.filter(c,e,tp)
	return RD.IsLegendCard(c) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,POS_FACEUP)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,1),m,tp,list[1])
end