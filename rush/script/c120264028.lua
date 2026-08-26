local cm,m=GetID()
cm.name="莓果新人·羞怯小莓"
function cm.initial_effect(c)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.downtg)
	e1:SetValue(-1500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Down
function cm.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()==100 and c:IsRace(RACE_AQUA)
end
function cm.condition(e)
	return Duel.IsExistingMatchingCard(cm.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function cm.downtg(e,c)
	return c:IsFaceup()
end