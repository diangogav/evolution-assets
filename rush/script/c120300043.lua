local cm,m=GetID()
local list={120264001,120222025}
cm.name="虫虚空洞"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return (aux.IsMaterialListCode(c,list[1]) or aux.IsMaterialListCode(c,list[2]))
		and c:IsLevelBelow(9) and c:IsRace(RACE_GALAXY)
end