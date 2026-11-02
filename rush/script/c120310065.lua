local cm,m=GetID()
cm.name="跨越境界的疾风之门"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsAttackBelow(2000)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)>0
		and tc:IsControlerCanBeChanged() end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc and tc:IsLocation(LOCATION_MZONE) and tc:IsControlerCanBeChanged() then
		Duel.GetControl(tc,tp,PHASE_MAIN1+PHASE_MAIN2,1)
	end
end