local cm,m=GetID()
local list={120105001,120115001}
cm.name="七星道巫师"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function cm.spfilter(c,e,tp)
	return c:IsLevelBelow(7) and c:IsRace(RACE_SPELLCASTER) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c,e,tp)
	return c:IsCode(list[2]) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,3,3,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if chk==0 then return Duel.GetMZoneCount(tp,g)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsCode(list[1]) then
			RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.exfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
		end
	end
end