local cm,m=GetID()
cm.name="融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end