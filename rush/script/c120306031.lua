local cm,m=GetID()
cm.name="雅耳典娜的圣枪"
function cm.initial_effect(c)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e2)
end
--Union
function cm.filter(c)
	return c:IsRace(RACE_FAIRY)
end