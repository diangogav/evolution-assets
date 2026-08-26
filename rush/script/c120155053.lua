local cm,m=GetID()
cm.name="幻刃急攻"
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
function cm.costfilter(c)
	return c:IsLevelBelow(6) and c:IsRace(RACE_WYRM) and c:IsAbleToGraveAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	return Duel.GetAttacker():IsControler(1-tp)
		and c and c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_WYRM)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1,nil,nil,function(g)
	return g:GetFirst():GetAttack()
end)
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local atk=e:GetLabel()
	if atk>0 and tc:IsFaceup() and tc:IsRelateToBattle() then
		RD.AttachAtkDef(e,tc,-atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end