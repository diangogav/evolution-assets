local cm,m=GetID()
local list={120294023,120294065}
cm.name="分机"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND+LOCATION_GRAVE)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.exfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(list[2])
end
function cm.posfilter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
			local posfilter=RD.Filter(cm.posfilter,e,tp)
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSCHANGE,posfilter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				RD.ChangePosition(sg,e,tp,REASON_EFFECT)
			end)
		end
	end
end