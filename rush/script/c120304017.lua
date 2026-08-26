local cm,m=GetID()
cm.name="缠龙的探索者 谢尔纳"
function cm.initial_effect(c)
	--Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Position
function cm.costfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and c:IsCanTurnSet()
end
function cm.exfilter(c)
	return c:IsRace(RACE_WYRM) and RD.IsDefense(c,2400) and c:IsLocation(LOCATION_GRAVE)
		and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_SET,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE) then
			Duel.BreakEffect()
			if RD.SendDeckTopToGraveAndExists(tp,1,cm.exfilter,1,nil) then
				local tc=Duel.GetOperatedGroup():GetFirst()
				if Duel.SelectEffectYesNo(tp,tc,aux.Stringid(m,1)) then
					Duel.SendtoHand(tc,nil,REASON_EFFECT)
				end
			end
		end
	end)
end