local cm,m=GetID()
local list={120285065,120130000,120181002}
cm.name="蒂迈欧之眼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter1(c,e,tp)
	return c:IsFaceup() and RD.IsLegendCode(c,list[2]) and c:IsCanBeFusionMaterial()
		and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_FMATERIAL)
end
function cm.matfilter2(c,e,tp)
	return c:IsFaceup() and c:IsCode(list[3]) and c:IsCanBeFusionMaterial()
		and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_FMATERIAL)
end
function cm.matfilter(c,e,tp)
	return (cm.matfilter1(c,e,tp) and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,list[2]))
		or (cm.matfilter2(c,e,tp) and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,list[3]))
end
function cm.spfilter(c,e,tp,tc,code)
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,code)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.matfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local mat=Duel.GetMatchingGroup(cm.matfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if mat:GetCount()==0 then return end
	local mat1=mat:Filter(RD.IsLegendCode,nil,list[2])
	local mat2=mat:Filter(Card.IsCode,nil,list[3])
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local code=RD.SelectOption(tp,
		{mat1:GetCount()>0,aux.Stringid(m,1),list[2]},
		{mat2:GetCount()>0,aux.Stringid(m,2),list[3]}
	)
	if code==list[2] then
		mat=mat1
	else
		mat=mat2
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local tc=mat:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,cm.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,code)
	local sc=sg:GetFirst()
	if sc then
		sc:SetMaterial(Group.FromCards(tc))
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end