local cm,m=GetID()
local list={120194005}
cm.name="神圣装甲 -炸裂罩力-"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return RD.IsLegendCode(c,list[1])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,3,3)
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		RD.AttachAtkDef(e,tc,-500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,2,nil,function(g)
				Duel.Destroy(g,REASON_EFFECT)
			end)
		end
	end
end