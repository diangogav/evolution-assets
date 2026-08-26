local cm,m=GetID()
cm.name="虚空噬骸兵·金剑鹰巨人"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,3) then
		local og=Duel.GetOperatedGroup():Filter(cm.exfilter,nil)
		local ct=og:GetCount()
		if ct>1 then
			local c=e:GetHandler()
			if c:IsFaceup() and c:IsRelateToEffect(e) then
				RD.AttachExtraAttack(e,c,ct-1,aux.Stringid(m,ct-1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end
			local dg=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
			if ct==3 and og:GetClassCount(Card.GetLevel)==1 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,3)) then
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end