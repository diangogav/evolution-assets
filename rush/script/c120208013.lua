local cm,m=GetID()
cm.name="黑手握手者"
function cm.initial_effect(c)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7)
end
function cm.posfilter(c,e,tp)
	return c:IsAttackPos() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,1,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
			local filter=RD.Filter(cm.posfilter,e,tp)
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				RD.ChangePosition(sg,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
			end)
		end
	end)
end