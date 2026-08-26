local cm,m=GetID()
local list={120213023,120285039}
cm.name="机械蛋球机器人"
function cm.initial_effect(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Extra Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_FUSION_MATERIAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(list[2])
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,RD.EnableChangeCode(c,list[1],LOCATION_MZONE))
end