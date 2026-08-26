local cm,m=GetID()
cm.name="全爱之女神"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureZero(c,aux.Stringid(m,0),cm.sumcon)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Avoid Battle Damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Summon Procedure
function cm.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()==0
end
function cm.sumcon(c,e,tp)
	return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()==0
end
function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(cm.filter,c:GetControler(),LOCATION_MZONE,0,nil)*1000
end
--Avoid Battle Damage
function cm.target(e,c)
	return c:IsAttack(0)
end