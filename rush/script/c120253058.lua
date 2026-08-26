local cm,m=GetID()
cm.name="陨石龙之爪"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(cm.excon)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetCondition(cm.excon)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_FIRE+ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end
--Atk Up
function cm.excon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return not tc:IsType(TYPE_EFFECT) and tc:IsType(TYPE_FUSION)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)