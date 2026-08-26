local cm,m=GetID()
local list={120277003,120277051}
cm.name="混沌哨兵"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter1,cm.matfilter2)
	--Special Summon Condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(cm.splimit)
	c:RegisterEffect(e1)
	--Cannot To Hand & Deck & Extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(cm.condition)
	e2:SetTarget(cm.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e2,e3)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter1(c)
	return c:IsAttackAbove(1500)
end
function cm.matfilter2(c)
	return c:IsAttackBelow(1500)
end
--Special Summon Condition
function cm.splimit(e,se,sp,st)
	return se and se:GetHandler():IsCode(list[1],list[2])
end
--Cannot To Hand & Deck & Extra
function cm.condition(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.target(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end