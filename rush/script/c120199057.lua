local cm,m=GetID()
cm.name="对冲突"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
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
		and c and c:IsControler(tp) and c:IsFaceup() and c:IsLevelAbove(10)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local c=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		RD.AttachBattleIndes(e,tc,1,nil,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		if c and c:IsRelateToBattle() and c:IsFaceup() then
			RD.AttachBattleIndes(e,c,1,nil,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		end
	end
end