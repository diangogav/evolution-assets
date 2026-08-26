local cm,m=GetID()
cm.name="水镜蛇"
function cm.initial_effect(c)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,nil,0,0,cm.matcheck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.confilter1(c)
	return c:IsRace(RACE_DRAGON) or c:IsRace(RACE_HYDRAGON)
end
function cm.confilter2(c)
	return c:IsType(TYPE_MONSTER) and not cm.confilter1(c)
end
function cm.costfilter(c)
	return not c:IsType(TYPE_FUSION) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_EARTH) and c:IsRace(RACE_DRAGON)
end
function cm.matfilter(c)
	return c:IsRace(RACE_DRAGON)
end
function cm.matcheck(tp,sg,fc)
	return sg:IsExists(cm.exfilter,1,nil) and sg:GetCount()>=3
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_GRAVE,0,1,nil)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)