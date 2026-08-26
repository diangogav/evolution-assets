local cm,m=GetID()
local list={120196006,120196050}
cm.name="虚钢主演机"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.filter(c)
	return ((c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and RD.IsDefense(c,500))
		 or c:IsCode(list[2])) and c:IsAbleToHand()
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (tc1:IsType(TYPE_NORMAL) and tc2:IsCode(list[2]))
		or (tc2:IsType(TYPE_NORMAL) and tc1:IsCode(list[2]))
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostSendDeckTopToGrave(3)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectGroupAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),cm.check,tp,LOCATION_GRAVE,0,1,2,nil,function(g)
			Duel.BreakEffect()
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end