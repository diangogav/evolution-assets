local cm,m=GetID()
local list={120222001}
cm.name="咩～界 绵羊水妖"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[1])
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
cm.cost=RD.CostChangeSelfPosition(POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)
	end)
end