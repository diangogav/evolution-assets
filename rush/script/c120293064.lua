local cm,m=GetID()
local list={120244060,120235063}
cm.name="援奏之指挥盗贼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Level Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Level Up
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PSYCHO) and not c:IsAttack(1300)
		and c:IsAbleToDeckOrExtraAsCost()
end
function cm.setfilter(c)
	return c:IsCode(list[1],list[2]) and c:IsSSetable()
end
function cm.posfilter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachLevel(e,c,3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if RD.CanSelectAndSet(aux.Stringid(m,1),aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,true)~=0 then
			local filter=RD.Filter(cm.posfilter,e,tp)
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				RD.ChangePosition(sg,e,tp,REASON_EFFECT)
			end)
		end
	end
end