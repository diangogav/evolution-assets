local cm,m=GetID()
cm.name="腐灼的罪人"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)