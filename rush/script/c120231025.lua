local cm,m=GetID()
cm.name="电子狮鹫"
function cm.initial_effect(c)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.filter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_MACHINE)
		and RD.IsCanAttachEffectIndes(c,tp,cm.indval)
		and (not c:IsAttribute(ATTRIBUTE_LIGHT) or Duel.IsPlayerCanDraw(tp,1))
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if tc:IsAttribute(ATTRIBUTE_LIGHT) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end)
end