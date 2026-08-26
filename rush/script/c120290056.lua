local cm,m=GetID()
local list={120290039}
cm.name="宝牙的仪式"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Counter
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,cm.ctfilter)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
--Special Summon Counter
function cm.ctfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_RITUAL)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)==0
end
function cm.matfilter(c)
	return c:IsLocation(LOCATION_HAND)
end
function cm.spfilter(c)
	return c:IsCode(list[1])
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetOperation(cm.limop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.limop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(cm.chainlm)
	e:Reset()
end
function cm.chainlm(e,rp,tp)
	return tp==rp
end