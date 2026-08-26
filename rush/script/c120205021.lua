local cm,m=GetID()
cm.name="捕食炮击变色龙"
function cm.initial_effect(c)
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
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsLPBelow(tp,1000) and Duel.GetLP(tp)~=Duel.GetLP(1-tp)
end
cm.cost=RD.CostSendDeckTopToGrave(5)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))
		RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end