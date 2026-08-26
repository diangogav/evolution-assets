local cm,m=GetID()
cm.name="新种掠夺萝卜"
function cm.initial_effect(c)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanAttachEffectIndes(e:GetHandler(),tp,cm.indval)
end
cm.cost=RD.CostSendDeckBottomToGrave(1,function(g)
	return g:GetFirst():GetRace()
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if e:GetLabel()==RACE_PLANT then
			RD.AttachAtkDef(e,c,700,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end