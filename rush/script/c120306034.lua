local cm,m=GetID()
local list={120125001,120125003}
cm.name="真红眼火龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND+LOCATION_GRAVE)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.exfilter(c)
	return RD.IsLegendCard(c) and c:IsType(TYPE_NORMAL)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
			RD.CanDraw(aux.Stringid(m,2),tp,1)
		end
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(cm.count)
	Duel.RegisterEffect(e1,tp)
	RD.CreateCannotActivateEffect(e,aux.Stringid(m,2),cm.aclimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1,0)
end
function cm.count(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(list[2]) then
		RD.AddTurnFlagCounter(tp,m)
	end
end
function cm.aclimit(e,re,tp)
	if RD.GetTurnFlagCounter(tp,m)<2 then return false end
	local tc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and tc:IsCode(list[2])
end