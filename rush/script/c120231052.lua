local cm,m=GetID()
cm.name="魔将 雅灭鲁拉-武枪"
function cm.initial_effect(c)
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
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP,true)
function cm.target(e,c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_CELESTIALWARRIOR+RACE_WARRIOR)
end