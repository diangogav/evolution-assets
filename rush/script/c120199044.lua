local cm,m=GetID()
cm.name="奇装天铠"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsLevelAbove(7) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function cm.costcheck(g,e,tp)
	return g:GetClassCount(Card.GetRace)==g:GetCount()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,g)
end
cm.cost=RD.CostSendGraveSubToDeckTopOrBottom(cm.costfilter,cm.costcheck,3,3,aux.Stringid(m,1),aux.Stringid(m,2))
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			RD.CanSelectAndDoAction(aux.Stringid(m,3),aux.Stringid(m,4),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				RD.AttachAtkDef(e,sg:GetFirst(),-1500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
end