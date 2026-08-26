local cm,m=GetID()
cm.name="和平龙"
function cm.initial_effect(c)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Recover
function cm.confilter(c)
	return c:IsType(TYPE_SPELL)
end
function cm.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
		and Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_GRAVE,0,nil)==3
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,3,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,1000,REASON_EFFECT,true)
	Duel.Recover(1-tp,1000,REASON_EFFECT,true)
	Duel.RDComplete()
end