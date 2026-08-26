local cm,m=GetID()
cm.name="联合之椅"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter1(c)
	return c:IsFaceup() and c:IsAttack(0)
end
function cm.confilter2(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c,e,tp)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(cm.confilter1,tp,LOCATION_MZONE,0,nil)==3
		and eg:IsExists(cm.confilter2,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,LOCATION_MZONE,0,1,2,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)~=0 and Duel.GetFlagEffect(tp,m)==0 then
			RD.CreateHintEffect(e,aux.Stringid(m,1),tp,0,1,RESET_PHASE+PHASE_END)
			RD.CreateCannotDirectAttackEffect(e,nil,tp,0,LOCATION_MZONE,RESET_PHASE+PHASE_END)
			RD.CreateCannotSelectBattleTargetEffect(e,cm.atkcon,nil,cm.atklimit,tp,0,LOCATION_MZONE,RESET_PHASE+PHASE_END)
			Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
		end
	end)
end
function cm.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsDefensePos,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.atklimit(e,c)
	return not c:IsDefensePos()
end