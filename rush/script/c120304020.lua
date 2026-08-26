local cm,m=GetID()
cm.name="绿缠龙-格里雷"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.tdfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,800,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,cm.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
				RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
			end)
		end
	end
end