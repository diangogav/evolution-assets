local cm,m=GetID()
cm.name="银线暴空想龙"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
function cm.exfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
cm.cost=RD.CostSendOnFieldToGrave(cm.costfilter,1,1,true)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,500,0,reset)
		if not Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
			RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,1),reset)
		end
	end
end