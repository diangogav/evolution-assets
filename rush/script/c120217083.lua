local cm,m=GetID()
cm.name="吓人僵尸大胜利"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_ZOMBIE)
end
function cm.posfilter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function cm.atkfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_ZOMBIE)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,2,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,3,nil,function(g)
		local sg=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil)
		local atk=Duel.GetMatchingGroupCount(cm.atkfilter,tp,LOCATION_GRAVE,0,nil)*100
		if RD.ChangePosition(g,e,tp,REASON_EFFECT)~=0 and sg:GetCount()>0 and atk~=0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			Duel.BreakEffect()
			sg:ForEach(function(tc)
				RD.AttachAtkDef(e,tc,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
end