local cm,m=GetID()
cm.name="超可爱执行者茶休！"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsFaceup() and c:IsLevel(6) and RD.IsDefense(c,500) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevel(6) and RD.IsDefense(c,500)
end
function cm.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
cm.cost=RD.CostSendMZoneToDeckTopOrBottom(cm.costfilter,1,1,aux.Stringid(m,1),aux.Stringid(m,2))
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,3),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end