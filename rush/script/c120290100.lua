local cm,m=GetID()
local list={120290100}
cm.name="暗狱皇 阿巴德"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Multiple Attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Multiple Attack
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.ConditionSummonOrSpecialSummonMainPhase(e)
		and Duel.IsAbleToEnterBP() and RD.IsCanAttachExtraAttack(c,1)
end
cm.cost=RD.CostPayLP(500)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachExtraAttack(e,c,1,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,1),m,tp,list[1])
end