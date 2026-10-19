local cm,m=GetID()
local list={120310011}
cm.name="碧牙试速龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.filter(c)
	return (c:IsCode(list[1]) or (c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON))) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			local tc=g:GetFirst()
			RD.AttachAtkDef(e,c,tc:GetLevel()*100,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			Duel.BreakEffect()
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end