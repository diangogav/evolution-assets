local cm,m=GetID()
cm.name="振乐姬 大号月刃斧手"
function cm.initial_effect(c)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function cm.filter1(c)
	return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_WIND)
end
function cm.filter2(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_WARRIOR)
end
function cm.thfilter(c)
	return (cm.filter1(c) or cm.filter2(c)) and c:IsAbleToHand()
end
function cm.check(g)
	if g:GetCount()<2 then return false end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (cm.filter1(tc1) and cm.filter2(tc2)) or (cm.filter1(tc2) and cm.filter2(tc1))
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsSummonTurn(c) and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,c)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),cm.check,tp,LOCATION_GRAVE,0,2,2,nil,function(g)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotActivateEffect(e,aux.Stringid(m,1),cm.aclimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not (tc:IsAttribute(ATTRIBUTE_WIND) and tc:IsRace(RACE_WARRIOR+RACE_BEAST))
end