local cm,m=GetID()
local list={CARD_CODE_OTS}
cm.name="外宇宙逆转领地"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(cm.upcon)
	e2:SetTarget(cm.uptg)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(cm.indcon)
	e3:SetTarget(cm.indtg)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
end
--Activate
function cm.confilter(c)
	return c:IsCode(list[1])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(cm.confilter,tp,LOCATION_GRAVE,0,nil)
	return mg:GetClassCount(Card.GetRace)>=5
end
--Atk Up
function cm.upcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.uptg(e,c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.indcon(e)
	local tp=e:GetHandlerPlayer()
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return Duel.GetTurnPlayer()~=tp and mg:GetClassCount(Card.GetRace)==3
end
function cm.indtg(e,c)
	return c:IsFaceup()
end