local cm,m=GetID()
local list={120310067,120310044}
cm.name="圣洁人 连接者"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevel(8) and c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_CYBERSE)
end
--To Hand
function cm.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler())
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_RTOHAND,cm.filter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
			local ct=mg:GetClassCount(Card.GetRace)
			local c=e:GetHandler()
			if c:IsFaceup() and c:IsRelateToEffect(e) and ct>=3 then
				RD.AttachPierce(e,c,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end
		end
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[2])
end