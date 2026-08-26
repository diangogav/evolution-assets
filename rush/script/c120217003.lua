local cm,m=GetID()
cm.name="超魔辉兽 大霸道王［R］"
function cm.initial_effect(c)
	--Activate Limit
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(cm.actcon)
	e1:SetValue(cm.actlimit)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
	--Special Summon Check
	if not cm.global_check then
		cm.global_check=true
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge:SetOperation(cm.spcheckop)
		Duel.RegisterEffect(ge,0)
	end
end
--Activate Limit
function cm.actcon(e)
	return RD.MaximumMode(e) and Duel.GetFlagEffect(1-e:GetHandlerPlayer(),m)~=0
end
function cm.actlimit(e,re,tp)
	local tc=re:GetHandler()
	return tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() and tc:IsLevelBelow(10) and re:IsActiveType(TYPE_MONSTER)
end
--Special Summon Check
function cm.spfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFaceup() and c:IsLevelAbove(5)
end
function cm.spcheckop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(0,m)==0 and eg:IsExists(cm.spfilter,1,nil,0) then
		Duel.RegisterFlagEffect(0,m,RESET_PHASE+PHASE_END,0,1)
	end
	if Duel.GetFlagEffect(1,m)==0 and eg:IsExists(cm.spfilter,1,nil,1) then
		Duel.RegisterFlagEffect(1,m,RESET_PHASE+PHASE_END,0,1)
	end
end