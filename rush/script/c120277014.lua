local cm,m=GetID()
cm.name="昆遁忍虫 刺又之独角仙"
function cm.initial_effect(c)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(cm.condition)
	e1:SetValue(cm.indes)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Indes
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
function cm.condition(e)
	return Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function cm.indes(e,c)
	return c:IsAttackAbove(2000)
end