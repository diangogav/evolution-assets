local cm,m=GetID()
cm.name="波涛融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_FISH)
end
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_FISH)
		and c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_FISH)
end
function cm.exfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_FISH)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,5,nil)
end