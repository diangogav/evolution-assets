local cm,m=GetID()
local list={120274047,120274046}
cm.name="腕龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end