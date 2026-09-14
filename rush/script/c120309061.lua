local cm,m=GetID()
cm.name="传说的派对"
function cm.initial_effect(c)
	--Fake Legend
	RD.EnableFakeLegend(c,LOCATION_HAND+LOCATION_GRAVE)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.atktg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCondition(cm.condition)
	e3:SetTarget(cm.indtg)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Atk Up
function cm.atktg(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and RD.IsBaseDefense(c,300)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cm.condition(e)
	return Duel.IsExistingMatchingCard(cm.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end