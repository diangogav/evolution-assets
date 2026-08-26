local cm,m=GetID()
cm.name="最强斗志"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.posfilter(c,e,tp)
	return c:IsDefensePos() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	return tc:IsControler(1-tp) and tc:IsLevelBelow(9) and bc and bc:IsDefensePos()
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateAttack() then return end
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		if RD.ChangePosition(tc,e,tp,REASON_EFFECT,POS_FACEUP_ATTACK)~=0 and tc:IsType(TYPE_NORMAL) then
			RD.AttachAtkDef(e,tc,1000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end