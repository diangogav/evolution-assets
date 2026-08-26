local cm,m=GetID()
cm.name="潜行狙击手"
function cm.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_dice=true
--Recover
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,99,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	for i=1,e:GetLabel() do
		local d=Duel.TossDice(tp,1)
		if d~=1 and d~=6 then ct=ct+1 end
	end
	if ct==0 then return end
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,ct,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end