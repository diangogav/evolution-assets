local cm,m=GetID()
local list={120309037}
cm.name="云海龙 内佩拉"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Counter
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,cm.ctfilter)
	--Union
	local e1=RD.RegisterUnionEffect(c,cm.filter,cm.condition,nil,cm.operation)
	e1:SetCategory(e1:GetCategory()|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	--Atk Down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(cm.downtg)
	e2:SetValue(-400)
	c:RegisterEffect(e2)
end
--Special Summon Counter
function cm.ctfilter(c)
	return not c:IsSummonLocation(LOCATION_GRAVE)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
end
function cm.spfilter(c,e,tp)
	return c:IsCode(list[1]) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)==0
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP,true)
end
--Atk Down
function cm.downtg(e,c)
	return c:IsFaceup()
end