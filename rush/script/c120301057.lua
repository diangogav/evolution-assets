local cm,m=GetID()
local list={120301060}
cm.name="疾行少校"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.target)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(cm.condition)
	e2:SetTarget(cm.target)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c,fc,sub)
	return c:IsFusionType(TYPE_EFFECT) and c:IsRace(RACE_WARRIOR) and RD.IsDefenseBelow(c,2000)
end
--Atk Up
function cm.confilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>=2600
		and c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
function cm.condition(e)
	return Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.target(e,c)
	return e:GetHandler()~=c and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_EARTH)
		and c:IsRace(RACE_WARRIOR)
end