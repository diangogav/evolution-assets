local cm,m=GetID()
cm.name="海龙骑士"
function cm.initial_effect(c)
	--Confirm
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Confirm
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c,tc)
	return RD.IsSameCode(c,tc)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_FACEDOWN,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil,function(g)
		Duel.ConfirmCards(tp,g)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,0,LOCATION_GRAVE,1,nil,g:GetFirst())
			and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end)
end