local cm,m=GetID()
cm.name="邪恶耍球人"
function cm.initial_effect(c)
	--Change Race
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return not c:IsPublic() and c:IsAttribute(ATTRIBUTE_LIGHT) and RD.IsDefense(c,500)
		and Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,c:GetRace())
end
function cm.filter(c,race)
	return c:IsFaceup() and (not c:IsRace(race) or not c:IsRace(RACE_FIEND))
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1,function(g)
	return g:GetFirst():GetRace()
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	local filter=RD.Filter(cm.filter,race)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		local b1=RD.IsCanChangeRace(tc,RACE_FIEND)
		local b2=RD.IsCanChangeRace(tc,race)
		local op=RD.SelectOption(tp,{b1,aux.Stringid(m,1)},{b2,aux.Stringid(m,2)})
		if op==1 then
			RD.ChangeRace(e,tc,RACE_FIEND,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
		if op==2 then
			RD.ChangeRace(e,tc,race,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end