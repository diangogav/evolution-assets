local cm,m=GetID()
cm.name="莓果新人·欢乐小莓"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.posfilter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and (c:IsFacedown() or c:IsCanTurnSet())
end
cm.cost=RD.CostSendHandOrFieldToGrave(Card.IsAbleToGraveAsCost,1,1,true,nil,nil,function(g)
	return g:GetFirst():GetBaseAttack()
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=e:GetLabel()
		RD.AttachAtkDef(e,c,1500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		if atk==100 then
			local filter=RD.Filter(cm.posfilter,e,tp)
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
				local tc=g:GetFirst()
				local pos=POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE
				if tc:IsPosition(POS_FACEUP_ATTACK) then
					pos=POS_FACEDOWN_DEFENSE
				elseif not tc:IsCanTurnSet() then
					pos=POS_FACEUP_ATTACK
				end
				pos=Duel.SelectPosition(tp,tc,pos)
				RD.ChangePosition(tc,e,tp,REASON_EFFECT,pos)
			end)
		end
	end
end