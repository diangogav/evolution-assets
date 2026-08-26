local cm,m=GetID()
local list={120235020,120196050}
cm.name="苍救天使 卢阿"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.costfilter(c,e,tp)
	return not c:IsPublic() and c:IsRace(RACE_WARRIOR)
end
function cm.thfilter(c)
	return c:IsCode(list[2]) and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
		Duel.BreakEffect()
		local sg,og=RD.SendDeckTopToGraveAndCanSelect(tp,3,aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),1,1)
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end
	end
end