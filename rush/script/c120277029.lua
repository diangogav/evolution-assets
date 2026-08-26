local cm,m=GetID()
cm.name="魔力动物骑士"
function cm.initial_effect(c)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.target1)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Level Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.target2)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.target1(e,c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
--Level Up
function cm.target2(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST)
end