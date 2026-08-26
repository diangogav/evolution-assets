local cm,m=GetID()
local list={120170029,120196050}
cm.name="花牙封 绘都兰世"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
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
function cm.costfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,c,e:GetHandler():GetCode())
end
function cm.filter(c,code)
	return c:IsRace(RACE_PLANT) and not c:IsCode(code)
end
function cm.setfilter(c)
	return c:IsCode(list[2]) and c:IsSSetable()
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():GetCode()) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local filter=RD.Filter(cm.filter,c:GetCode())
		RD.SelectAndDoAction(aux.Stringid(m,1),aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			RD.CopyCode(e,c,g:GetFirst(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			RD.CanSelectAndSet(aux.Stringid(m,2),aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,true)
		end)
	end
end