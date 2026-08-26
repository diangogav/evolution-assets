local cm,m=GetID()
cm.name="逆鳞火斩"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGraveAsCost()
end
function cm.desfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end
function cm.costcheck(g,e,tp)
	local lv=g:GetSum(Card.GetLevel)
	return Duel.IsExistingMatchingCard(cm.desfilter,tp,0,LOCATION_MZONE,1,nil,lv)
end
cm.cost=RD.CostSendHandSubToGrave(cm.costfilter,cm.costcheck,2,2,nil,nil,function(g)
	return g:GetSum(Card.GetLevel)
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local lv=e:GetLabel()
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil,lv)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local filter=RD.Filter(cm.desfilter,lv)
	RD.SelectAndDoAction(HINTMSG_DESTROY,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end