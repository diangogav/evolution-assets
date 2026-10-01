local cm,m=GetID()
local list={120309055,120309056}
cm.name="游乐园挂饰纪念品"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c,e,tp)
	return c:IsType(TYPE_UNION) and c:IsLevel(4) and c:IsRace(RACE_BEASTWARRIOR)
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)~=0
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_ONFIELD,0,1,nil,list[1])
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_ONFIELD,0,1,nil,list[2]) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end)
	end
end