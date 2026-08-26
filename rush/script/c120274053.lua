local cm,m=GetID()
cm.name="荣华梦中之丝绸蚕"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,false,cm.matfilter1,cm.matfilter2)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.target)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Cannot Be Fusion Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(cm.fuslimit)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter1(c)
	return c:IsLevel(7,8,9) and c:IsRace(RACE_INSECT) and c:IsFusionType(TYPE_EFFECT)
end
function cm.matfilter2(c)
	return c:IsRace(RACE_INSECT) and c:IsFusionType(TYPE_EFFECT)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.target(e,c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
--Cannot Be Fusion Material
function cm.fuslimit(e,c,sumtype)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end