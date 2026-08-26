local cm,m=GetID()
local list={120244012,120244011,120196050}
cm.name="名蔷薇女巫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.costfilter(c,e,tp)
	return not c:IsPublic() and ((c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)) or c:IsType(TYPE_EQUIP))
end
function cm.thfilter(c)
	return c:IsCode(list[1],list[2],list[3]) and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToHand()
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,4) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local sg,og=RD.SendDeckTopToGraveAndCanSelect(tp,4,aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),1,1)
	if sg:GetCount()>0 then
		Duel.BreakEffect()
		RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
	end
end