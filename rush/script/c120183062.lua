local cm,m=GetID()
cm.name="攻击减俸"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local c=Duel.GetAttackTarget()
	return tc:IsControler(1-tp) and tc:IsLevelBelow(8) and c and c:IsControler(tp) and c:IsFaceup()
end
cm.cost=RD.CostPayLP(600)
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		RD.AttachAtkDef(e,tc,-400,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachBattleIndes(e,tc,1,nil,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		local c=Duel.GetAttackTarget()
		if c and c:IsRelateToBattle() and c:IsFaceup() then
			RD.AttachBattleIndes(e,c,1,nil,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		end
	end
end