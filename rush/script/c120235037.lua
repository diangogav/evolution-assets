local cm,m=GetID()
local list={120235016,120235005}
cm.name="星猫·毁灭喵"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon
function cm.costfilter(c)
	return RD.IsDefense(c,200) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.spfilter(c,e,tp)
	return RD.IsDefense(c,200) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLocation(LOCATION_MZONE)
end
function cm.costcheck(g,e,tp)
	local sg=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_GRAVE,0,g,e,tp)
	return sg:CheckSubGroup(cm.check,2,2)
end
function cm.check(g)
	return g:GetClassCount(Card.GetLevel)==1
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetMZoneCount(tp)>1
		and sg:CheckSubGroup(cm.check,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectGroupAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),cm.check,tp,LOCATION_GRAVE,0,2,2,nil,e,POS_FACEUP)~=0 then
		local og=Duel.GetOperatedGroup():Filter(cm.exfilter,nil)
		og:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,2200,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end