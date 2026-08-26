local cm,m=GetID()
local list={120231024}
cm.name="嵌合粉碎龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedureRep(c,true,true,cm.matfilter,2,63,list[1])
	-- Fusion Flag
	RD.CreateFusionSummonFlag(c,20283031)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.uptg)
	e2:SetValue(cm.upval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c,fc,sub)
	return c:IsRace(RACE_MACHINE)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_SPELL,TYPE_SPELL,true)
--Atk Up
function cm.uptg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
function cm.upval(e)
	local c=e:GetHandler()
	if c:GetFlagEffect(20283031)~=0 then
		return c:GetMaterialCount()*100
	else
		return 0
	end
end