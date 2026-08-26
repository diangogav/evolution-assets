local cm,m=GetID()
cm.name="焰魔的强袭"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MAXIMUM) and c:IsAbleToGraveAsCost()
end
function cm.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MAXIMUM)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,3,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_MZONE,nil)
	if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,function(sg)
			Duel.BreakEffect()
			RD.AttachAtkDef(e,sg:GetFirst(),1000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end