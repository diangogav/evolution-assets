local cm,m=GetID()
cm.name="日落逆转"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(cm.condition2)
	c:RegisterEffect(e2)
	--Condition
	e1:SetCondition(cm.condition1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.confilter(c,tp)
	return RD.IsPreviousControler(c,tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT)
end
function cm.spfilter(c,e,tp)
	return RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEDOWN_DEFENSE)
end
function cm.exfilter(c,tp)
	return RD.IsCanAttachEffectIndes(c,tp,cm.indval)
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and ep~=tp
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(cm.confilter,1,nil,tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,POS_FACEDOWN_DEFENSE)~=0 then
		local filter=RD.Filter(cm.exfilter,tp)
		RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_ONFIELD,0,1,3,e:GetHandler(),function(g)
			Duel.BreakEffect()
			g:ForEach(function(tc)
				RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end)
	end
end