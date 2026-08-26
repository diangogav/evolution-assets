local cm,m=GetID()
local list={120102002,120145007}
cm.name="千年龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end