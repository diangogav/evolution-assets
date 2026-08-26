local cm,m=GetID()
local list={120247002}
cm.name="鹰身三姐妹［L］"
function cm.initial_effect(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Indes (Normal)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Indes (MaximumMode)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCondition(RD.MaximumMode)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Level Up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(RD.MaximumMode)
	e3:SetValue(5)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,RD.EnableChangeCode(c,list[1],LOCATION_MZONE))
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)