local cm,m=GetID()
cm.name="昆遁忍虫 念珠之空蝉"
function cm.initial_effect(c)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.target1)
	c:RegisterEffect(e1)
	--Avoid Battle Damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.target2)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Pierce
function cm.target1(e,c)
	return c:IsFaceup() and RD.IsHasContinuousEffect(c)
		and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_INSECT)
end
--Avoid Battle Damage
function cm.target2(e,c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end