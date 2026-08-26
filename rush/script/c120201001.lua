local cm,m=GetID()
local list={120201007,120201009}
cm.name="炎之剑士"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end