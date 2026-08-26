local cm,m=GetID()
cm.name="种族变更光线"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetRace())
end
function cm.filter(c,race)
	return c:IsFaceup() and RD.IsCanChangeRace(c,race)
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1,function(g)
	return g:GetFirst():GetRace()
end)
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	local filter=RD.Filter(cm.filter,race)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,3,nil,function(g)
		g:ForEach(function(c)
			RD.ChangeRace(e,c,race,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end)
end