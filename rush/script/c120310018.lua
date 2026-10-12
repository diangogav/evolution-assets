local cm,m=GetID()
cm.name="疯狂犯罪者·猴女"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.thfilter(c)
	return c:IsFaceup() and c:IsLevel(6) and c:IsAbleToHand()
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,500,0,reset)
		RD.AttachLevel(e,c,2,reset)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_RTOHAND,cm.thfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			Duel.BreakEffect()
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotSpecialSummonEffect(e,aux.Stringid(m,2),aux.TRUE,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateHintEffect(e,aux.Stringid(m,3),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (RD.IsBaseDefense(c,1100) and c:IsAttribute(ATTRIBUTE_DARK))
end