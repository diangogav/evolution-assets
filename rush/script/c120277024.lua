local cm,m=GetID()
cm.name="卡片防御士"
function cm.initial_effect(c)
	--Cannot To Hand & Deck & Extra
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(cm.indcon)
	e1:SetTarget(cm.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e2)
	--Atk Up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(cm.atkcon)
	e3:SetTarget(cm.atktg)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Cannot To Hand & Deck & Extra
function cm.indcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
--Atk Up
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL+TYPE_FUSION) and c:IsRace(RACE_WARRIOR)
end
function cm.atkcon(e)
	return Duel.IsExistingMatchingCard(cm.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.atktg(e,c)
	return c:IsFaceup()
end