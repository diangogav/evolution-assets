local cm,m=GetID()
cm.name="古代冰炎壁"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.costcheck(g)
	return g:GetClassCount(Card.GetRace)==1
end
function cm.filter(c,tp)
	return c:IsFaceup() and c:IsLevelBelow(8) and RD.IsCanAttachEffectIndes(c,tp,cm.indval)
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,2,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end)
end