local cm,m=GetID()
local list={120301010}
cm.name="水灵术师 艾莉娅"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function cm.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSummonOrSpecialSummonMainPhase(e:GetHandler())
end
cm.cost=RD.CostSendHandOrFieldToGrave(cm.costfilter,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,0,LOCATION_GRAVE,1,1,nil,function(g)
		RD.SendToDeckTop(g,e,tp,REASON_EFFECT)
		local tc=g:GetFirst()
		local sumlimit=function(e,c)
			return RD.IsSameOriginalCode(c,tc)
		end
		RD.CreateCannotSummonEffect(e,aux.Stringid(m,1),sumlimit,tp,0,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.CreateCannotFaceupSpecialSummonEffect(e,aux.Stringid(m,2),sumlimit,tp,0,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,3),m,tp,list[1])
end