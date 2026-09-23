local cm,m=GetID()
local list={CARD_CODE_FuSiGiNaKoBiTo,120309052}
cm.name="啃食的小人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.filter(c)
	return c:IsCode(list[2]) and c:IsAbleToDeck()
end
cm.cost=RD.CostChangeSelfPosition(POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,2) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			Duel.BreakEffect()
			if RD.SendToDeckTop(g,e,tp,REASON_EFFECT)~=0 then
				Duel.Recover(tp,600,REASON_EFFECT)
			end
		end)
	end
end