local cm,m=GetID()
local list={120109051}
cm.name="暴风眼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(2,2)
	e1:SetCondition(RD.ConditionSummonTurn)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.matfilter(c)
	return c:IsOnField() and c:IsLevelBelow(6) and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsCode(list[1])
end
function cm.exfilter(c)
	return c:IsLevelBelow(6) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end