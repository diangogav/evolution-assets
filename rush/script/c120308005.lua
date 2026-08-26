local cm,m=GetID()
cm.name="比翼连鳞"
function cm.initial_effect(c)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	--Double Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(aux.IsUnionState)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
--Union
function cm.filter(c)
	return c:IsLevelBelow(8)
end