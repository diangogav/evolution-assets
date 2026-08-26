local cm,m=GetID()
cm.name="魔力动物魔女"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.costfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsLevel(7,8) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsPublic()
end
function cm.costcheck(g,e,tp)
	return Duel.IsPlayerCanDraw(tp,g:GetCount())
end
cm.cost=RD.CostShowGroupHand(cm.costfilter,cm.costcheck,1,2,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetDraw(tp,e:GetLabel())
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=RD.Draw()
	if ct==0 then return end
	RD.SelectAndDoAction(HINTMSG_TODECK,Card.IsAbleToDeck,p,LOCATION_HAND,0,ct,ct,nil,function(g)
		Duel.BreakEffect()
		RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
	end)
end