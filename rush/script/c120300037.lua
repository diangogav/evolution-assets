local cm,m=GetID()
local list={120300046}
cm.name="冥迹神 伊思里亚"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	RD.AddRitualProcedure(c)
	--Special Summon Condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(cm.splimit)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Cannot Activate
	local e3,e4,e5=RD.ContinuousSummonNotChainTrap(c,20300037,cm.filter)
	--Atk Up
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetCondition(cm.condition)
	e6:SetTarget(cm.target)
	e6:SetValue(3000)
	c:RegisterEffect(e6)
	--Pierce
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(m,1))
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_PIERCE)
	e7:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetCondition(cm.condition)
	e7:SetTarget(cm.target)
	c:RegisterEffect(e7)
	--Continuous Effect
	RD.AddContinuousEffect(c,e2,e3,e4,e5,e6,e7)
end
--Special Summon Limit
function cm.splimit(e,se,sp,st)
	return se and se:GetHandler():IsCode(list[1])
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
--Cannot Activate
function cm.filter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsRace(RACE_BEASTWARRIOR)
end
--Atk Up
function cm.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.target(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_BEASTWARRIOR)
		and c~=e:GetHandler()
end