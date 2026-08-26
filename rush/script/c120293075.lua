local cm,m=GetID()
cm.name="THE☆战斗撞击剑"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(200)
	c:RegisterEffect(e1)
	--Cannot Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(cm.eqcon)
	e2:SetValue(cm.limit)
	c:RegisterEffect(e2)
	--Position
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(cm.poscon)
	e3:SetOperation(cm.posop)
	c:RegisterEffect(e3)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup()
end
--Cannot Activate
function cm.eqcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(e:GetHandlerPlayer())
end
function cm.limit(e,re,tp)
	local tc=re:GetHandler()
	return tc:IsType(TYPE_EQUIP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
--Position
function cm.poscon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=Duel.GetAttackTarget()
	return Duel.GetAttacker()==ec and tc and tc:IsControler(1-tp)
		and tc:IsDefensePos() and not tc:IsStatus(STATUS_BATTLE_DESTROYED)
end
function cm.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	if tc:IsRelateToBattle() and tc:IsDefensePos() then
		Duel.Hint(HINT_CARD,0,m)
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
