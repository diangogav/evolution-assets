local cm,m=GetID()
cm.name="超自然保护机关 疯狂犯罪"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and RD.IsDefense(c,1100) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,2) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
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