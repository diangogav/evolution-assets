local cm,m=GetID()
cm.name="暗物质加油芙蕾雅"
function cm.initial_effect(c)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Pierce
function cm.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and RD.IsCanAttachPierce(c)
end
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
		and (not c:IsPosition(POS_FACEUP_DEFENSE) or c:IsCanTurnSet())
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
cm.cost=RD.CostChangeSelfPosition()
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachPierce(e,g:GetFirst(),aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local filter=RD.Filter(cm.posfilter,e,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,3),HINTMSG_POSCHANGE,filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
			local tc=g:GetFirst()
			local pos=POS_FACEUP_DEFENSE+POS_FACEDOWN_DEFENSE
			if tc:IsPosition(POS_FACEUP_DEFENSE) then
				pos=POS_FACEDOWN_DEFENSE
			elseif not tc:IsCanTurnSet() then
				pos=POS_FACEUP_DEFENSE
			end
			pos=Duel.SelectPosition(tp,tc,pos)
			RD.ChangePosition(tc,e,tp,REASON_EFFECT,pos)
		end)
	end)
end