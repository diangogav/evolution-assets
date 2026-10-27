local cm,m=GetID()
local list={120299001,120310030}
cm.name="次元电波通讯器"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.filter(c)
	return c:IsAbleToGrave()
end
function cm.spfilter(c,e,tp)
	return (c:IsCode(list[1]) or (c:IsType(TYPE_FUSION) and c:IsLevel(9)
		and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_CYBERSE)))
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 and RD.SendToGraveAndExists(g) then
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP,true)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[2])
end