local cm,m=GetID()
local list={120310100}
cm.name="墓地阴影"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.filter(c)
	return (c:IsCode(list[1]) or c:IsType(TYPE_MONSTER)) and c:IsAbleToDeck()
end
function cm.check(g)
	local ct=g:GetCount()
	if g:IsExists(Card.IsCode,1,nil,list[1]) then
		return ct==1 or ct==5
	else
		return ct==5
	end
end
cm.cost=RD.CostPayLP(500)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,1,5) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),cm.check,tp,LOCATION_GRAVE,0,1,5,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
				Duel.BreakEffect()
				RD.AttachAtkDef(e,g:GetFirst(),-1500,-1500,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,3),m,tp,list[1])
end