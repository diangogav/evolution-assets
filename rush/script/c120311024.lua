local cm,m=GetID()
local list={120311021,120311026,120307014}
cm.name="邪心英雄 恶刃魔鬼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Special Summon Condition
	RD.OnlySpecialSummonByEffect(c,cm.splimit)
	--Must Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_FIEND)
end
--Special Summon Condition
function cm.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(list[2],list[3]) or se:GetValue()==SUMMON_VALUE_DARK_FUSION
end
--Must Attack
function cm.condition(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) and Duel.IsBattlePhase()
end