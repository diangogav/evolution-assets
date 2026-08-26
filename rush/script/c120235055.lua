local cm,m=GetID()
cm.name="暴风轮"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return c:IsLocation(LOCATION_DECK)
end
function cm.tdfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAbleToDeck()
end
function cm.check(g)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	aux.GCheckAdditional=cm.check
	RD.SelectGroupAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),aux.TRUE,tp,0,LOCATION_GRAVE,2,7,nil,function(g)
		aux.GCheckAdditional=nil
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT,cm.exfilter,6,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_RTOHAND,cm.tdfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
				RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
			end)
		end
	end)
	aux.GCheckAdditional=nil
end