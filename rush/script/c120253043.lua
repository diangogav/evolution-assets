local cm,m=GetID()
local list={120109025,120253012}
cm.name="旋紫斩奏之琴拨现演罪犯"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
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
	return not c:IsPublic() and c:IsType(TYPE_SPELL)
end
function cm.spfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PSYCHO) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
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
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,ct,ct,nil,e,POS_FACEUP)
end