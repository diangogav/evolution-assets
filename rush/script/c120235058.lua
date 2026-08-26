local cm,m=GetID()
cm.name="上级屏蔽积木"
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
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsLevelAbove(5)
end
function cm.filter(c,e,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_DRAGON+RACE_MACHINE) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return RD.IsCanChangePosition(tc,e,tp,REASON_EFFECT)
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,2,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=eg:GetFirst()
		if tc:IsRelateToEffect(e) then
			g:AddCard(tc)
		end
		RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
	end)
end