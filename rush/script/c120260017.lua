local cm,m=GetID()
cm.name="奇怪吸引子"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter1(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToGraveAsCost()
end
function cm.costfilter2(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_CYBERSE) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.costcheck2(g)
	return g:GetClassCount(Card.GetLevel)>=5
end
cm.cost1=RD.CostSendHandToGrave(cm.costfilter1,1,1)
cm.cost2=RD.CostSendGraveSubToDeck(cm.costfilter2,cm.costcheck2,5,5)
cm.cost=RD.CostChoose(HINTMSG_TOGRAVE,cm.cost1,HINTMSG_TODECK,cm.cost2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	RD.TargetDraw(tp,2)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.Draw()
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotActivateEffect(e,aux.Stringid(m,2),cm.aclimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not tc:IsRace(RACE_CYBERSE)
end