local cm,m=GetID()
local list={120235001,120254064}
cm.name="超级谱气斗士·汽枪兵"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLocation(LOCATION_GRAVE)
end
function cm.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,3) then
		local g=Duel.GetOperatedGroup():Filter(cm.exfilter,nil)
		local ct=g:GetClassCount(Card.GetRace)
		local mg=Duel.GetMatchingGroup(cm.thfilter,1-tp,LOCATION_MZONE,0,nil)
		if ct>0 and mg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RTOHAND)
			local sg=mg:Select(1-tp,ct,ct,nil)
			if sg:GetCount()>0 then
				Duel.BreakEffect()
				Duel.HintSelection(sg)
				RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
			end
		end
	end
end