local cm,m=GetID()
cm.name="属性变更弹"
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
		and Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function cm.filter(c,attr)
	return c:IsFaceup() and not c:IsAttribute(attr)
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1,function(g)
	return g:GetFirst():GetAttribute()
end)
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	local filter=RD.Filter(cm.filter,attr)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,3,nil,function(g)
		g:ForEach(function(c)
			RD.ChangeAttribute(e,c,attr,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end)
end