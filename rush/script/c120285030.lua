local cm,m=GetID()
cm.name="继承的魔战士"
function cm.initial_effect(c)
	--Copy Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Copy Code
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c,code)
	return (c:IsAttack(2600) or RD.IsDefense(c,2600)) and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) and not c:IsCode(code)
end
function cm.costcheck(g,e,tp)
	return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,g,e:GetHandler():GetCode())
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():GetCode()) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local filter=RD.Filter(cm.filter,c:GetCode())
		RD.SelectAndDoAction(aux.Stringid(m,1),aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			RD.CopyCode(e,c,g:GetFirst(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end