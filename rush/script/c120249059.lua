local cm,m=GetID()
cm.name="化学化蔑视"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	return Duel.GetAttacker():IsControler(1-tp)
		and c and c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_PYRO)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		local tc=Duel.GetAttacker()
		local c=Duel.GetAttackTarget()
		if c and c:IsRelateToBattle()
			and tc and tc:IsRelateToBattle()
			and tc:IsLevelAbove(1) and c:GetLevel()>tc:GetLevel()
			and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end