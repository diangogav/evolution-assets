local cm,m=GetID()
cm.name="湧军机 陆炎"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandConfirmSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.target)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return not c:IsLevel(8) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_MACHINE)
		and not c:IsPublic()
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.target(e,c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end