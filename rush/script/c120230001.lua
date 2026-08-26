local cm,m=GetID()
local list={120106001,120220001}
cm.name="龙骑士 盖亚"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end
