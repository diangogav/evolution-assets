local cm,m=GetID()
local list={120130000}
cm.name="黑混沌之魔术师"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
end