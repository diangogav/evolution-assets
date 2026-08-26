local cm,m=GetID()
local list={120287014,120287015}
cm.name="饶有情趣的菓子袴着"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
function cm.ritual_mat_filter(c)
	return not c:IsLocation(LOCATION_HAND) or c:IsType(TYPE_NORMAL)
end
--Activate
function cm.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_AQUA)
end
function cm.spfilter(c)
	return c:IsCode(list[1],list[2])
end