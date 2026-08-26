local cm,m=GetID()
local list={120263005,120263008}
cm.name="元素英雄 电流翼侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Only Fusion Summon
	RD.OnlyFusionSummon(c)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,aux.FALSE,cm.spfilter,cm.matfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end

--Fusion Summon
function cm.spfilter(c)
	return c:IsHasEffect(EFFECT_ONLY_FUSION_SUMMON) and c:IsLevel(6,7,8) and c:IsRace(RACE_WARRIOR)
end
function cm.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler())
end