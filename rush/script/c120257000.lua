local cm,m=GetID()
local list={120145000,120125001}
cm.name="暗黑魔龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end