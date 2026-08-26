local cm,m=GetID()
cm.name="出发区"
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
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Draw Count
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DRAW_COUNT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	e3:SetCondition(cm.drawcon)
	e3:SetValue(cm.drawval)
	c:RegisterEffect(e3)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=1
end
cm.cost=RD.CostSendDeckTopToGrave(2)
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
--Draw Count
function cm.drawcon(e)
	local tp=Duel.GetTurnPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)>0
end
function cm.drawval(e)
	local tp=Duel.GetTurnPlayer()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	return math.max(1,6-ct)
end