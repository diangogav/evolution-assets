local cm,m=GetID()
cm.name="奇迹融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeckBottom)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsHasEffect(EFFECT_ONLY_FUSION_SUMMON) and c:IsRace(RACE_WARRIOR)
end
function cm.exfilter(c)
	return c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end