local cm,m=GetID()
local list={120253028}
cm.name="流星群突入龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelAbove(6) and c:IsFusionAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK)
end