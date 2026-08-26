local cm,m=GetID()
cm.name="歇斯底里的双眼"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition1)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(cm.condition2)
	c:RegisterEffect(e3)
end
--Activate
function cm.confilter1(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function cm.confilter2(c,tp)
	return c:IsControler(tp)
end
function cm.filter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter1,1,nil,1-tp)
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter2,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,2,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT)~=0 then
			local sg=Duel.GetOperatedGroup():Filter(Card.IsType,nil,TYPE_RITUAL)
			if sg:GetCount()>0 then
				local tc1,tc2=sg:GetFirst(),sg:GetNext()
				local actlimit=function(e,re,tp)
					if tc1 and RD.IsSameOriginalCode(re:GetHandler(),tc1) then
						return true
					elseif tc2 and RD.IsSameOriginalCode(re:GetHandler(),tc2) then
						return true
					else
						return false
					end
				end
				RD.CreateCannotActivateEffect(e,aux.Stringid(m,1),actlimit,tp,0,1,RESET_PHASE+PHASE_END)
			end
		end
	end)
end