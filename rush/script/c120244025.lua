local cm,m=GetID()
cm.name="空中传送机·最大式"
function cm.initial_effect(c)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,12,nil,TYPE_MONSTER)
end
function cm.filter(c)
	return c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeck()
end
function cm.costcheck(g,e,tp)
	return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,2,g)
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,10,10)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,2,3,nil,function(g)
		RD.SendToDeckTop(g,e,tp,REASON_EFFECT)
	end)
end