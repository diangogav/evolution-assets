local cm,m=GetID()
cm.name="王家魔族·守护者"
function cm.initial_effect(c)
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
cm.trival=RD.ValueDoubleTributeAttrRace(nil,RACE_FIEND)
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,0,LOCATION_MZONE,1,nil)
		and RD.IsCanAttachDoubleTribute(e:GetHandler(),cm.trival)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachDoubleTribute(e,c,cm.trival,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
			RD.AttachLevel(e,c,1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end