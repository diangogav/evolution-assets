local cm,m=GetID()
cm.name="终焰魔神 绝望大炎魔［L］"
function cm.initial_effect(c)
	--Indes (Normal)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.indval1)
	c:RegisterEffect(e1)
	--Indes (MaximumMode)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCondition(RD.MaximumMode)
	e2:SetValue(cm.indval2)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Indes
cm.indval1=RD.ValueEffectIndesType(0,TYPE_TRAP)
cm.indval2=RD.ValueEffectIndesType(0,TYPE_SPELL+TYPE_TRAP)
