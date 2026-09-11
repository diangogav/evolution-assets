local cm,m=GetID()
local list={120309036}
cm.name="云海翔龙 青绿龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.atkcon)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.indcon)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Position
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.poscon)
	e3:SetOperation(cm.posop)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and RD.IsUnionMonsterCard(c)
end
function cm.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function cm.atkval(e)
	return Duel.GetMatchingGroupCount(cm.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*400
end
--Indes
function cm.indcon(e)
	return Duel.IsExistingMatchingCard(cm.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,3,nil)
end
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
--Position
function cm.exfilter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
		and not Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cm.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.Hint(HINT_CARD,0,m)
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end