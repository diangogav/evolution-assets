local cm,m=GetID()
cm.name="天翔变化"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,cm.matcheck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cm.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_FAIRY)
		and (fc:IsRace(RACE_CELESTIALWARRIOR) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND))
end