local cm,m=GetID()
local list={120293046,120261058}
cm.name="惑精 银莲冥王星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Procedure
	RD.AddHandConfirmSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,2)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	--Check
	if not cm.global_check then
		cm.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(cm.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsCode(list[1],list[2]) and not c:IsPublic()
end
--Fusion Summon
function cm.spfilter(c)
	return c:IsRace(RACE_GALAXY) and RD.IsDefense(c,1900)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,20311010)~=0
end
--Check
function cm.checkfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT)
end
function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	local ph=Duel.GetCurrentPhase()
	if (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and eg:IsExists(cm.checkfilter,1,nil,p) then
		Duel.RegisterFlagEffect(p,20311010,RESET_PHASE+PHASE_MAIN1+PHASE_MAIN2,0,1)
	end
end