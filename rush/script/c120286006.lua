local cm,m=GetID()
cm.name="幻遭之奇美拉蛇"
function cm.initial_effect(c)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
function cm.filter(c)
	return c:IsAbleToDeck()
end
cm.cost=RD.CostSendDeckTopToGrave(2,function(g)
	return g:FilterCount(cm.costfilter,nil)
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,0,LOCATION_GRAVE,1,2,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) and e:GetLabel()>0 then
			RD.CanDamage(aux.Stringid(m,1),tp,400)
		end
	end)
end