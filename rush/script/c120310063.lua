local cm,m=GetID()
cm.name="疯狂犯罪者骇入"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition1)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.activate)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c,e,tp)
	return c:IsAttackPos() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)~=0
			and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSCHANGE,filter,tp,LOCATION_MZONE,0,1,1,nil,function(sg)
				RD.ChangePosition(sg,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
			end)
		end
	end)
end