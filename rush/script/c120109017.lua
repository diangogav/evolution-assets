local cm,m=GetID()
cm.name="尖头狩猎 食尸鬼胡狼"
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
function cm.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cm.tdcheck(g)
	return g:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return g:CheckSubGroup(cm.tdcheck,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,1-tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.thfilter),cm.tdcheck,tp,0,LOCATION_GRAVE,2,2,nil,function(g)
		RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
	end)
end