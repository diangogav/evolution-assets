local cm,m=GetID()
cm.name="疯狂犯罪者·空鹰女"
function cm.initial_effect(c)
	--Attack Twice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Attack Twice
function cm.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevel(6)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1
		and Duel.IsAbleToEnterBP() and RD.IsCanAttachExtraAttack(e:GetHandler(),1)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachExtraAttack(e,c,1,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			if Duel.Destroy(g,REASON_EFFECT)~=0 then
				RD.AttachAtkDef(e,c,600,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end
		end)
	end
end