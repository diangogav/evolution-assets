local cm,m=GetID()
local list={120199047}
cm.name="怒怒怒二垒手"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Extra Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Extra Tribute
cm.trival=RD.ValueDoubleTributeAttrRace(ATTRIBUTE_FIRE,nil)
function cm.confilter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanAttachDoubleTribute(e:GetHandler(),cm.trival)
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
cm.cost=RD.CostPayLP(500)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachDoubleTribute(e,c,cm.trival,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end