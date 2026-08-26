local cm,m=GetID()
local list={120125001,120238029}
cm.name="流星黑龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end