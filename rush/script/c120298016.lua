local cm,m=GetID()
cm.name="叛骨的命运"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevelBelow(5)
		and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE)
		and (RD.IsCanAttachBattleIndes(c,1) or RD.IsCanAttachEffectIndes(c,tp,cm.indval))
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,2,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachBattleIndes(e,tc,1,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end)
end