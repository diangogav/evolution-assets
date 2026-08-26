local cm,m=GetID()
local list={120170002,120196050}
cm.name="可能甜心-具象化：D"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
function cm.filter(c,code)
	return c:IsRace(RACE_PSYCHO) and not c:IsCode(code)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function cm.thfilter(c)
	return c:IsCode(list[1],list[2]) and c:IsAbleToHand()
end
cm.cost=RD.CostPayLP(100)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():GetCode()) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local filter=RD.Filter(cm.filter,c:GetCode())
		RD.SelectAndDoAction(aux.Stringid(m,1),aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			RD.CopyCode(e,c,g:GetFirst(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			if not Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
				RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
					RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
				end)
			end
		end)
	end
end