local cm,m=GetID()
cm.name="太阴月力车马龙"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.confilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local ct1=Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_GRAVE,0,nil)
	local ct2=Duel.GetMatchingGroupCount(cm.confilter,1-tp,LOCATION_GRAVE,0,nil)
	return ct2>ct1
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct1=Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_GRAVE,0,nil)
		local ct2=Duel.GetMatchingGroupCount(cm.confilter,1-tp,LOCATION_GRAVE,0,nil)
		local atk=math.abs(ct1-ct2)*100
		RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.AttachPierce(e,c,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end
end