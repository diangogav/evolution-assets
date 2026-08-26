local cm,m=GetID()
cm.name="混沌战士运动服士 –干燥的使者–"
function cm.initial_effect(c)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.costfilter(c)
	return RD.IsDefense(c,500) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.tdfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAbleToDeck()
end
function cm.costcheck(g)
	return g:GetClassCount(Card.GetAttribute)==g:GetCount()
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,cm.tdfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			RD.AttachCannotDirectAttack(e,c,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end