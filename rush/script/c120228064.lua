local cm,m=GetID()
cm.name="火场盗贼怪力"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return RD.IsPreviousControler(c,tp) and c:IsPreviousLocation(LOCATION_SZONE)
		and c:GetPreviousSequence()<5 and c:IsReason(REASON_EFFECT)
end
function cm.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSSetable()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_PSYCHO)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(cm.confilter,1,nil,tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cm.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSet(aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,2,nil,e)~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.exfilter,tp,LOCATION_MZONE,0,1,3,nil,function(g)
			Duel.BreakEffect()
			g:ForEach(function(tc)
				RD.AttachBattleIndes(e,tc,1,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end)
	end
end