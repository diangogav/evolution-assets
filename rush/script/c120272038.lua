local cm,m=GetID()
local list={120235001,120254065}
cm.name="超级谱气斗士·等离子剑士"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Cannot Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(cm.sumcon)
	e2:SetTarget(cm.sumlimit)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Up
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
function cm.atkval(e,c)
	local g=Duel.GetMatchingGroup(cm.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	return g:GetSum(Card.GetLevel)*200
end
--Cannot Special Summon
function cm.sumfilter(c)
	return c:IsType(TYPE_MAXIMUM) and c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER)
end
function cm.sumcon(e)
	return Duel.IsExistingMatchingCard(cm.sumfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil)
end
function cm.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_HAND) and c:GetAttribute()~=ATTRIBUTE_FIRE
end