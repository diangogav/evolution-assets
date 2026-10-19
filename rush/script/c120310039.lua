local cm,m=GetID()
local list={120225024,120310049,120310039}
cm.name="Eα版燃龙兽"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter1,cm.matfilter2)
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter1(c)
	return c:IsFusionType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON)
end
function cm.matfilter2(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON) and RD.IsDefense(c,900)
end
--Discard Deck
function cm.thfilter(c)
	return c:IsCode(list[2]) and c:IsAbleToHand()
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,3)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,list[1]) then
		RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,2,nil,function(sg)
			Duel.BreakEffect()
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,3),m,tp,list[3])
end