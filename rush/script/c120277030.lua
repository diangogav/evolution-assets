local cm,m=GetID()
cm.name="魔力动物双剑士"
function cm.initial_effect(c)
	--Cannot Activate
	local e1,e2,e3=RD.ContinuousSummonNotChainTrap(c,20277030,cm.filter)
	--Level Up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(cm.target)
	e4:SetValue(2)
	c:RegisterEffect(e4)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,e4)
end
--Cannot Activate
function cm.filter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsRace(RACE_BEAST)
end
--Level Up
function cm.target(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST)
end