local cm,m=GetID()
local list={120231024}
cm.name="原始电子龙"
function cm.initial_effect(c)
	--Change Code
	RD.AddContinuousEffect(c,RD.EnableChangeCode(c,list[1]))
end
