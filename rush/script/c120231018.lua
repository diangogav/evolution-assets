local cm,m=GetID()
cm.name="终焰之绝望"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.exfilter(c)
	return c:IsFaceup() and RD.IsMaximumMode(c)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	local tc=Duel.GetAttacker()
	return tc:IsControler(1-tp) and tc:IsLevelBelow(8)
		and c and c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_MAXIMUM)
end
cm.cost=RD.CostPayLP(600)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc and tc:IsRelateToBattle() and RD.SendToDeckAndExists(tc,e,tp,REASON_EFFECT)
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
		Duel.Damage(1-tp,600,REASON_EFFECT)
	end
end