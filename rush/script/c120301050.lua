local cm,m=GetID()
local list={120235052}
cm.name="苍救的祈誓"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND+LOCATION_GRAVE)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,cm.matcheck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return cm.matfilter1(c) or cm.matfilter2(c)
end
function cm.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WARRIOR)
end
function cm.matfilter2(c)
	return c:IsFusionType(TYPE_EFFECT) and c:IsRace(RACE_FAIRY)
end
function cm.spfilter(c)
	return c:IsRace(RACE_CELESTIALWARRIOR)
end
function cm.matcheck(tp,sg,fc)
	return sg:FilterCount(cm.matfilter1,nil)==1
end