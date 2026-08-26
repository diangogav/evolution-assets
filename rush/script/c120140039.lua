local cm,m=GetID()
cm.name="念动力前奏"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rec=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_MZONE,0,nil)*500
	if chk==0 then return rec>0 end
	RD.TargetRecover(tp,rec)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local rec=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_MZONE,0,nil)*500
	RD.Recover(nil,rec)
end