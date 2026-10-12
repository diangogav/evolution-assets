local cm,m=GetID()
cm.name="疯狂犯罪者干扰"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsFaceup() and c:IsType(TYPE_EFFECT)
		and not c:IsType(TYPE_MAXIMUM)
end
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendHandOrFieldToGrave(cm.costfilter,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotSpecialSummonEffect(e,aux.Stringid(m,1),aux.TRUE,tp,1,0,RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	RD.CreateHintEffect(e,aux.Stringid(m,2),tp,1,0,RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (RD.IsBaseDefense(c,1100) and c:IsAttribute(ATTRIBUTE_DARK))
end