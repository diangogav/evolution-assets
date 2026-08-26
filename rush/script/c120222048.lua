local cm,m=GetID()
cm.name="雨大都会"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	--Atk Up / Down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cm.uptg)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTarget(cm.downtg)
	e3:SetValue(-200)
	c:RegisterEffect(e3)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,2,nil)
end
--Atk Up / Down
function cm.uptg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA)
end
function cm.downtg(e,c)
	return c:IsFaceup() and not c:IsRace(RACE_AQUA)
end