local cm,m=GetID()
local list={120207007}
cm.name="鹰身女郎1"
function cm.initial_effect(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(cm.uptg)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,RD.EnableChangeCode(c,list[1],LOCATION_MZONE))
end
--Atk Up
function cm.uptg(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end