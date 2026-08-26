local cm,m=GetID()
cm.name="星辉心灰"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and c:IsCanTurnSet()
end
function cm.exfilter(c,tp)
	return c:IsControler(1-tp) and c:GetBaseAttack()>=2600
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_SET,filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil,function(g)
		local ex=g:IsExists(cm.exfilter,1,nil,tp)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)~=0 and ex then
			Duel.Recover(tp,1500,REASON_EFFECT)
		end
	end)
end