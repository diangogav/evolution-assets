local cm,m=GetID()
cm.name="侏罗纪绿洲"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cm.target)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
cm.cost=RD.CostSendDeckTopToGrave(2)
--Indes
function cm.target(e,c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER,TYPE_MONSTER,true)