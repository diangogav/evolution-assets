local cm,m=GetID()
cm.name="幻坏大铠户"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Indes Battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(cm.indcon1)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Indes Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(cm.indcon2)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(cm.indcon3)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_WYRM)
end
--Indes
function cm.indcon1(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsAttackPos()
end
function cm.indcon2(e)
	return Duel.GetFieldGroupCount(0,LOCATION_FZONE,LOCATION_FZONE)>0
end
function cm.indcon3(e)
	return e:GetHandler():GetEquipTarget() and cm.indcon2(e)
end
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)