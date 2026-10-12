local cm,m=GetID()
local list={120310062}
cm.name="疯狂犯罪者·鱼女"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Position
function cm.filter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevel(6)
end
function cm.thfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,2,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT)~=0
			and Duel.IsExistingMatchingCard(cm.exfilter,tp,0,LOCATION_MZONE,1,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
				Duel.BreakEffect()
				RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
			end)
		end
	end)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotSpecialSummonEffect(e,aux.Stringid(m,2),aux.TRUE,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateHintEffect(e,aux.Stringid(m,3),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (RD.IsBaseDefense(c,1100) and c:IsAttribute(ATTRIBUTE_DARK))
end