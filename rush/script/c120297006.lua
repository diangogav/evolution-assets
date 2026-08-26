local cm,m=GetID()
cm.name="行星神盾兵"
function cm.initial_effect(c)
	--Cannot To Hand & Deck & Extra
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Cannot To Hand & Deck & Extra
function cm.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and c:IsLocation(LOCATION_MZONE)
		and c:GetFlagEffect(20297006)==0
end
function cm.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetFlagEffect(20297006)==0
end
function cm.filter(c)
	return cm.filter1(c) or cm.filter2(c)
end
function cm.check(g)
	if g:GetCount()==1 then
		return cm.filter1(g:GetFirst())
	elseif g:GetCount()==2 then
		local tc1,tc2=g:GetFirst(),g:GetNext()
		return (cm.filter1(tc1) and cm.filter2(tc2)) or (cm.filter1(tc2) and cm.filter2(tc1))
	else
		return false
	end
end
cm.cost=RD.CostSendDeckTopToGrave(2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(aux.Stringid(m,1),cm.filter,cm.check,tp,LOCATION_ONFIELD,0,1,2,nil,function(g)
		g:ForEach(function(tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(m,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetLabel(1-tp)
			e1:SetCondition(cm.buffcon)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
			tc:RegisterEffect(e2)
			if not tc:IsImmuneToEffect(e) then
				tc:RegisterFlagEffect(20297006,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
			end
		end)
	end)
end
function cm.buffcon(e)
	return Duel.GetTurnPlayer()==e:GetLabel()
end