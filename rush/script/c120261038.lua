local cm,m=GetID()
cm.name="数据吞噬者"
function cm.initial_effect(c)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.costcheck(g,e,tp)
	return g:FilterCount(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)==1
end
function cm.tdfilter(c)
	return c:IsAbleToDeck()
end
cm.cost=RD.CostShowGroupHand(cm.costfilter,cm.costcheck,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,0,LOCATION_GRAVE,2,nil) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,0,LOCATION_GRAVE,2,2,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil,function(sg)
				Duel.BreakEffect()
				RD.AttachAtkDef(e,sg:GetFirst(),500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
end