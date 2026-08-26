local cm,m=GetID()
cm.name="健康斗士·拉蜜拉"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddHealthySummonProcedure(c,aux.Stringid(m,0),1000)
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
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
function cm.target(e,c)
	return c:IsFaceup() and RD.IsBaseDefense(c,1300) and c:IsRace(RACE_PYRO)
end