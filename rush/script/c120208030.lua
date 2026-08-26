local cm,m=GetID()
cm.name="生化螳螂"
function cm.initial_effect(c)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Down
function cm.costfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		RD.AttachAtkDef(e,tc,-300,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if RD.IsCanChangeRace(tc,RACE_INSECT) and Duel.SelectEffectYesNo(tp,tc,aux.Stringid(m,2)) then
			Duel.BreakEffect()
			RD.ChangeRace(e,tc,RACE_INSECT,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end