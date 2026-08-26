local cm,m=GetID()
cm.name="真红眼冥龙"
function cm.initial_effect(c)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.matfilter(c)
	return c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_FIRE)
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end