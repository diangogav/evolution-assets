local cm,m=GetID()
cm.name="大连击龙 齿车戒龙·爆裂［L］"
function cm.initial_effect(c)
	--Multiple Attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(m)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Multiple Attack
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.MaximumMode(e) and Duel.IsAbleToEnterBP() and RD.IsCanAttachExtraAttackMonster(e:GetHandler(),2)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachExtraAttackMonster(e,c,2,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachEndPhase(e,c,tp,m,cm.tdop,aux.Stringid(m,2),true)
	end
end
function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	RD.SendToDeckAndExists(e:GetLabelObject(),e,tp,REASON_EFFECT)
end