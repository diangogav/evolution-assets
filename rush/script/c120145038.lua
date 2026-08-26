local cm,m=GetID()
cm.name="哨艇 神力旧印号"
function cm.initial_effect(c)
	--Confirm
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Confirm
function cm.costfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_FACEDOWN,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		Duel.ConfirmCards(tp,g)
	end)
end