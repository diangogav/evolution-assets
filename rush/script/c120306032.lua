local cm,m=GetID()
cm.name="雅耳典娜的圣盾"
function cm.initial_effect(c)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Cannot To Hand & Deck & Extra
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e3:SetCondition(aux.IsUnionState)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e4)
	--Indes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_ONFIELD,0)
	e5:SetCondition(aux.IsUnionState)
	e5:SetTarget(cm.target)
	e5:SetValue(cm.indval)
	c:RegisterEffect(e5)
end
--Union
function cm.filter(c)
	return c:IsRace(RACE_FAIRY)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.target(e,c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end