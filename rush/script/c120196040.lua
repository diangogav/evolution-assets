local cm,m=GetID()
local list={120196042,120196041}
cm.name="迷宫的魔战车"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end