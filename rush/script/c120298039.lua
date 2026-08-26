local cm,m=GetID()
cm.name="进化之茧"
function cm.initial_effect(c)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,nil,nil,nil,nil,nil,nil,true)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.spfilter(c)
	return c:IsLevelBelow(8) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_INSECT)
end