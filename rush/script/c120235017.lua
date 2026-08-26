local cm,m=GetID()
cm.name="暗眼破星猫"
function cm.initial_effect(c)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Pierce
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevel(7,8)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() and RD.IsCanAttachPierce(e:GetHandler())
end
cm.cost=RD.CostSendDeckTopToGrave(2)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachPierce(e,c,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if RD.IsSpecialSummonMainPhase(c) then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end)
		end
	end
end