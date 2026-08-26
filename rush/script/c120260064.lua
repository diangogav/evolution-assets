local cm,m=GetID()
cm.name="美食之神童 迪安·凯特"
function cm.initial_effect(c)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Recover
function cm.confilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetRecover(tp,1000)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Recover()~=0 then
		local c=e:GetHandler()
		local ct=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if c:IsFaceup() and c:IsRelateToEffect(e) and ct>0 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,1)) then
			Duel.BreakEffect()
			RD.AttachAtkDef(e,c,ct*300,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end