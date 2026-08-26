local cm,m=GetID()
cm.name="以太逃脱"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsLevelAbove(7)
end
function cm.costfilter(c)
	return c:IsRace(RACE_WARRIOR+RACE_MACHINE) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function cm.tdfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return RD.IsCanChangePosition(tc,e,tp,REASON_EFFECT) and tc:IsCanTurnSet() end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and RD.ChangePosition(tc,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)~=0
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,cm.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
			RD.SendToDeckTop(g,e,tp,REASON_EFFECT)
		end)
	end
end