local cm,m=GetID()
cm.name="剑黎之魔术师"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spcon)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.indcon)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Special Summon Procedure
function cm.spfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetMatchingGroupCount(cm.spfilter,tp,0,LOCATION_MZONE,nil)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
function cm.confilter(c)
	return c:IsType(TYPE_SPELL)
end
function cm.indcon(e)
	return Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,6,nil)
end