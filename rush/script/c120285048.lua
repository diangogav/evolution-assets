local cm,m=GetID()
cm.name="等离子塑料模型 雷神俱-混合姬"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(cm.target)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.target(e,c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end