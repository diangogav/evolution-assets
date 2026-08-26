local cm,m=GetID()
cm.name="接合科技高天霸王龙"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddPrimeSummonProcedure(c,aux.Stringid(m,0),1800)
	--Level Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Level Down
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
function cm.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,3,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,2),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachLevel(e,g:GetFirst(),-3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,3),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_SZONE,1,1,nil,function(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end)
	end)
end