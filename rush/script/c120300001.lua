local cm,m=GetID()
local list={120264001,120222025}
cm.name="虚空噬骸兵·鹳式东方号"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost1=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
cm.cost2=RD.CostSendDeckTopToGrave(2)
cm.cost=RD.CostChoose(aux.Stringid(m,1),cm.cost1,aux.Stringid(m,2),cm.cost2,true)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local code=list[1]
		if e:GetLabel()==1 and RD.IsCanChangeCode(c,list[2]) then
			code=RD.SelectOption(tp,
				{true,aux.Stringid(m,3),list[1]},
				{true,aux.Stringid(m,4),list[2]})
		end
		RD.ChangeCode(e,c,code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end