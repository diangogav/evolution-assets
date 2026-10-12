local cm,m=GetID()
cm.name="接合科技P打孔机"
function cm.initial_effect(c)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e2)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end