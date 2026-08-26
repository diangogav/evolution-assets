local cm,m=GetID()
cm.name="莓果新人·幸福小莓 收获"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
cm.indval=RD.ValueEffectIndesType(0,TYPE_SPELL+TYPE_TRAP)
function cm.exfilter(c)
	return c:IsRace(RACE_AQUA)
end
cm.cost=RD.CostSendHandOrFieldToGrave(Card.IsAbleToGraveAsCost,1,2,true,nil,nil,Group.GetCount)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		RD.AttachAtkDef(e,c,ct*1500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,5,nil) then
			RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
	end
end