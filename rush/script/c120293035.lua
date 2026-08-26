local cm,m=GetID()
cm.name="混沌祈祷师"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.costfilter(c)
	return c:IsLevel(4) and c:IsAttack(500) and RD.IsDefense(c,1000) and c:IsAbleToDeckAsCost()
end
function cm.desfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,1000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_SZONE,1,1,nil,function(g)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end