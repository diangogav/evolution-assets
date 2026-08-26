local cm,m=GetID()
local list={120199047}
cm.name="背号39 球儿皇 霍姆"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.costfilter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,2,2,true)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,2500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
	RD.CreateHintEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateOnlyThisAttackEffect(e,20199028,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
end