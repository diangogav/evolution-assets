local cm,m=GetID()
cm.name="超越超速火山"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.costcheck(g,e,tp)
	return g:GetClassCount(Card.GetAttack)==g:GetCount()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
cm.cost=RD.CostSendGraveSubToDeckBottom(cm.costfilter,cm.costcheck,3,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsFaceup() and tc:IsType(TYPE_EFFECT) and tc:IsLevelBelow(8) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc and tc:IsRelateToBattle() then
		if Duel.Destroy(tc,REASON_EFFECT)==0 then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end