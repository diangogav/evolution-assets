local cm,m=GetID()
cm.name="超融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,cm.exfilter,0,LOCATION_MZONE,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Activate
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.matfilter(c)
	return c:IsOnField()
end
function cm.exfilter(c)
	return c:IsFaceup()
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(cm.limop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.limop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
	e:Reset()
end