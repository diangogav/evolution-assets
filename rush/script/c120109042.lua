local cm,m=GetID()
local list={120263009,120263006}
cm.name="元素英雄 泥球侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Only Fusion Summon
	RD.OnlyFusionSummon(c)
end