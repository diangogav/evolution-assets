local cm,m=GetID()
local list={120208002,120222025}
cm.name="银河舰混沌忘却龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.atkval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
--Atk Up
function cm.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_GALAXY)
end
function cm.exfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.atkval(e,c)
	local tp=c:GetControler()
	local atk=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_GRAVE,0,nil)*300
	if not Duel.IsExistingMatchingCard(cm.exfilter,tp,0,LOCATION_ONFIELD,1,nil) then
		atk=atk+1500
	end
	return atk
end