local cm,m=GetID()
cm.name="地缚灵的引诱"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return RD.IsCanChangeAttackTarget(Duel.GetAttacker()) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.ChangeAttackTarget(Duel.GetAttacker(),tp,Duel.GetAttackTarget())
end