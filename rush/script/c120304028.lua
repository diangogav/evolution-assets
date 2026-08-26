local cm,m=GetID()
local list={120196038}
cm.name="中间管理社员·经理"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.exfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(list[1])
end
cm.cost1=RD.CostPayLP(1200)
cm.cost2=RD.CostSendDeckTopToGrave(3)
cm.cost=RD.CostMerge(cm.cost1,cm.cost2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and RD.SendToDeckTop(c,e,tp,REASON_EFFECT)~=0
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
		RD.CanDraw(aux.Stringid(m,1),tp,1,true)
	end
end