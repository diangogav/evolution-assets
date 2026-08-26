local cm,m=GetID()
local list={120260025}
cm.name="电磁双剑"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Double Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetCondition(cm.atkcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_ROCK)
end
--Double Attack
function cm.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(list[1])
end