local cm,m=GetID()
local list={120257017,120222025,120249023}
cm.name="接合科技三角恐龙基地"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter,cm.matfilter)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Attack Thrice
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(cm.atkcon)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--Fusion Success
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCondition(cm.regcon)
	e3:SetOperation(cm.regop)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return not c:IsRace(RACE_MACHINE)
end
--Attack Thrice
function cm.atkcon(e)
	local c=e:GetHandler()
	return RD.IsSpecialSummonTurn(c) and c:GetFlagEffect(20257041)~=0
end
--Fusion Success
function cm.regfilter(c,code)
	return c:IsOriginalCodeRule(code) and c:IsLocation(LOCATION_GRAVE)
end
function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if g:IsExists(cm.regfilter,1,nil,list[2]) and g:IsExists(cm.regfilter,1,nil,list[3]) then
		c:RegisterFlagEffect(20257041,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end