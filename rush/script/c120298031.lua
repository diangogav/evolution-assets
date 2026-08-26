local cm,m=GetID()
local list={120298035,120298039}
cm.name="究极完全态大飞蛾"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
end