local cm,m=GetID()
local list={120222025}
cm.name="虚空噬骸兵·混沌战鹰巨人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelAbove(8) and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
--To Deck
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function cm.costcheck(g)
	return g:GetClassCount(Card.GetRace)==g:GetCount()
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,cm.tdfilter,tp,0,LOCATION_ONFIELD,1,2,nil,function(g)
		RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
	end)
end