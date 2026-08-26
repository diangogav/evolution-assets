local cm,m=GetID()
local list={120208004}
cm.name="咩～界 羊毛火妖"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[1])
end