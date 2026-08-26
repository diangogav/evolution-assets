local cm,m=GetID()
cm.name="斗气破坏力"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(cm.prccon)
	e3:SetTarget(cm.prctg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
--Pierce
function cm.prcfilter(c)
	return c:IsType(TYPE_EQUIP)
end
function cm.prccon(e)
	return Duel.IsExistingMatchingCard(cm.prcfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function cm.prctg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end