local cm,m=GetID()
local list={120304062,120304026,120304042}
cm.name="锐进执照"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return aux.IsMaterialListCode(c,list[2]) or aux.IsMaterialListCode(c,list[3])
end