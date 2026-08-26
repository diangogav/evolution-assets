local cm,m=GetID()
local list={120196050}
cm.name="额外探险者号"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.exfilter(c)
	return c:IsRace(RACE_GALAXY)
end
function cm.filter(c)
	return ((c:IsType(TYPE_NORMAL) and c:IsRace(RACE_GALAXY)) or c:IsCode(list[1]))
		and c:IsAbleToHand()
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (tc1:IsRace(RACE_GALAXY) and tc2:IsCode(list[1]))
		or (tc2:IsRace(RACE_GALAXY) and tc1:IsCode(list[1]))
end
cm.cost=RD.CostSendDeckTopToGrave(2)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,300,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,5,nil) then
			RD.CanSelectGroupAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),cm.check,tp,LOCATION_GRAVE,0,1,2,nil,function(g)
				RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
			end)
		end
	end
end