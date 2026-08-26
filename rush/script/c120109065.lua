local cm,m=GetID()
cm.name="指挥骑士"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.atktg)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Cannot Be Battle Target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetValue(cm.target)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Up
function cm.atktg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
--Cannot Be Battle Target
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function cm.condition(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and not RD.IsAttacking(e)
end
function cm.target(e,c)
	return c==e:GetHandler()
end