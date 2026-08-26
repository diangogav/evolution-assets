local cm,m=GetID()
cm.name="超魔基地 大霸基地"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cm.uptg)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(cm.target)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsLPBelowOpponent(tp,1)
end
--Atk Up
function cm.uptg(e,c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_MACHINE)
end
--Indes
function cm.target(e,c)
	return c:IsFaceup() and c:IsLevel(10) and c:IsRace(RACE_MACHINE)
end
cm.indval=RD.ValueEffectIndesType(TYPE_SPELL+TYPE_TRAP,TYPE_SPELL+TYPE_TRAP,true)