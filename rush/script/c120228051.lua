local cm,m=GetID()
cm.name="炎装 琴品焰形剑"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Cannot Be Battle Target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(cm.atkcon)
	e2:SetValue(cm.atktg)
	c:RegisterEffect(e2)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:GetOriginalRace()==RACE_PSYCHO
end
--Cannot Be Battle Target
function cm.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return not RD.IsAttacking(e) and ec and ec:GetControler()==e:GetHandlerPlayer()
end
function cm.atktg(e,c)
	return c:GetEquipCount()==0
end