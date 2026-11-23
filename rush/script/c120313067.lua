local cm,m=GetID()
cm.name="吸血鬼女郎"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) or Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsPlayerCanDiscardDeck(tp,1)
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,1)
	local p=RD.SelectOption(tp,
		{b1,aux.Stringid(m,1),tp},
		{b1,aux.Stringid(m,2),1-tp})
	if Duel.DiscardDeck(p,1,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsAbleToDeck() and Duel.SelectEffectYesNo(tp,tc,aux.Stringid(m,3)) then
			Duel.BreakEffect()
			RD.SendToDeckTop(tc,e,tp,REASON_EFFECT)
		end
	end
end