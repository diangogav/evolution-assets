local cm,m=GetID()
cm.name="钢击龙 齿车戒钢龙"
function cm.initial_effect(c)
	--Attack Twice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Attack Twice
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.costfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachBattleIndes(e,c,1,aux.Stringid(m,1),reset)
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,2),reset)
		local e1=RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,3),reset)
		e1:SetCondition(cm.atkcon)
	end
end
function cm.atkcon(e)
	return e:GetHandler():GetAttackedGroupCount()>0
end