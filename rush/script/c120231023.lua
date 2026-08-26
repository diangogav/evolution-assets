local cm,m=GetID()
local list={120231024}
cm.name="电子隐形龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(list[1])
end
--Def Up
function cm.confilter(c)
	return c:IsCode(list[1])
end
function cm.condition(e)
	return Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER)