local cm,m=GetID()
local list={120305057,120305056,120305058,120305003}
cm.name="YXZ-炮神龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedureSP(c,true,true,cm.matfilter,cm.check,2,3)
	RD.SetFusionMaterial(c,{list[1],list[2],list[3]},3,3)
	--Union Fusion
	RD.EnableUnionFusion(c,aux.Stringid(m,0))
	--Change Code
	RD.EnableChangeCode(c,list[4],LOCATION_EXTRA)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
function cm.matfilter(c,fc,sub)
	return c:IsFusionCode(list[1],list[2],list[3]) or (sub and c:CheckFusionSubstitute(fc))
		or RD.IsCanBeUnionFusionMaterial(c,list[1]) or RD.IsCanBeUnionFusionMaterial(c,list[2])
		or RD.IsCanBeUnionFusionMaterial(c,list[3])
end
function cm.matfilter1(c,fc,sub)
	return c:IsFusionCode(list[1]) or (sub and c:CheckFusionSubstitute(fc))
end
function cm.matfilter2(c,fc,sub)
	return c:IsFusionCode(list[2]) or (sub and c:CheckFusionSubstitute(fc))
end
function cm.matfilter3(c,fc,sub)
	return c:IsFusionCode(list[3]) or (sub and c:CheckFusionSubstitute(fc))
end
function cm.matfilter12(c,fc,sub)
	return RD.IsCanBeUnionFusionMaterial2(c,list[1],list[2])
end
function cm.matfilter13(c,fc,sub)
	return RD.IsCanBeUnionFusionMaterial2(c,list[1],list[3])
end
function cm.matfilter23(c,fc,sub)
	return RD.IsCanBeUnionFusionMaterial2(c,list[2],list[3])
end
function cm.check(g,tp,fc,chkf)
	if g:GetCount()==3 then
		return RD.CheckFusionMaterials(g,fc,true,{cm.matfilter1,cm.matfilter2,cm.matfilter3})
	else
		return RD.CheckFusionMaterials(g,fc,true,{cm.matfilter1,cm.matfilter23})
			or RD.CheckFusionMaterials(g,fc,true,{cm.matfilter2,cm.matfilter13})
			or RD.CheckFusionMaterials(g,fc,true,{cm.matfilter3,cm.matfilter12})
	end
end
--Special Summon
function cm.spfilter(c,e,tp)
	return c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_FUSION)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)
end