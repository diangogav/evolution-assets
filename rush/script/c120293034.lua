local cm,m=GetID()
cm.name="混沌素材"
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
	return c:IsLevel(4) and c:IsAttack(500) and RD.IsDefense(c,1000) and not c:IsPublic()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsLevel(8) and c:IsRace(RACE_WARRIOR)
end
cm.cost1=RD.CostShowHand(cm.costfilter,1,1)
cm.cost2=RD.CostSendDeckTopToGrave(2)
cm.cost=RD.CostMerge(cm.cost1,cm.cost2)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,1000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,1)) then
			Duel.BreakEffect()
			RD.AttachLevel(e,c,4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end