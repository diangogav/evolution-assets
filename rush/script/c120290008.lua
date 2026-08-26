local cm,m=GetID()
local list={CARD_CODE_OTS}
cm.name="外宇宙 爆裂忘却龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Change Race
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
--Change Race
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.spfilter(c,e,tp)
	return not c:IsRace(RACE_PYRO) and c:IsCode(list[1]) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeRace(e:GetHandler(),RACE_GALAXY)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeRace(e,c,RACE_GALAXY,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP,true)~=0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
			RD.AttachAtkDef(e,tc,700,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end