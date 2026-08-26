local cm,m=GetID()
local list={120294066}
cm.name="翼之魔兽 加尔瓦斯"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.target1)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.target2)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_BEAST)
end
function cm.target1(e,c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function cm.atkval(e)
	return Duel.GetMatchingGroupCount(cm.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*500
end
--Pierce
function cm.target2(e,c)
	return c:IsFaceup() and c:IsCode(list[1])
end