local cm,m=GetID()
cm.name="绝望狂魔 死核魔"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
		and RD.IsDefense(c,2400)
end