local cm,m=GetID()
cm.name="疾行骑兵"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,200,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if RD.IsSpecialSummonMainPhase(c) then
			local b1=Duel.IsPlayerCanDiscardDeck(tp,1)
			local b2=Duel.IsPlayerCanDiscardDeck(1-tp,1)
			local op=RD.SelectOption(tp,
				{b1,aux.Stringid(m,1)},
				{b2,aux.Stringid(m,2)},
				{true,aux.Stringid(m,3)}
			)
			if op==1 then
				Duel.DiscardDeck(tp,1,REASON_EFFECT)
			elseif op==2 then
				Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
			end
		end
	end
end