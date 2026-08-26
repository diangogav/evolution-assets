local cm,m=GetID()
local list={120199009,120199008}
cm.name="火面特忍 味噌快熟方便面"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Pierce
function cm.costfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,3,3)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,600,0,reset)
		RD.AttachPierce(e,c,aux.Stringid(m,1),reset)
	end
end