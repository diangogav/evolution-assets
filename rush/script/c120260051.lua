local cm,m=GetID()
cm.name="爱之安全"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(cm.indcon)
	e1:SetTarget(cm.indtg)
	e1:SetValue(cm.indval)
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
	return c:IsControler(tp) and c:IsFaceup()
		and c:GetBaseAttack()==0 and RD.IsBaseDefense(c,0) and c:IsRace(RACE_FAIRY)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.indcon(e)
	return e:GetHandler():GetEquipTarget()~=nil
end
function cm.indtg(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 and c:IsFacedown())
end
--Cannot Be Battle Target
function cm.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return not RD.IsAttacking(e) and ec and ec:GetControler()==e:GetHandlerPlayer()
end
function cm.atktg(e,c)
	return c:GetEquipCount()==0
end