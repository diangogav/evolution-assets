local cm,m=GetID()
local list={120196050,120253051}
cm.name="曼陀林掠夺者"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter(c)
	return c:IsCode(list[1],list[2]) and c:IsAbleToHand()
end
cm.cost=RD.CostPayLP(100)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local sg,g=RD.RevealDeckTopAndCanSelect(tp,3,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.thfilter,1,2)
	if sg:GetCount()>0 then
		RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
	end
	Duel.ShuffleDeck(tp)
end