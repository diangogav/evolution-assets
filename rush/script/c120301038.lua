local cm,m=GetID()
local list={120301046,120235021}
cm.name="苍救之幽暗 库拉戴思"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--Cannot Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetOperation(cm.actlimit)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Up
function cm.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.target(e,c)
	return c:IsFaceup() and c:IsRace(RACE_CELESTIALWARRIOR+RACE_WARRIOR)
end
--Cannot Activate
function cm.actlimit(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	if c:IsFaceup() and c:IsRace(RACE_CELESTIALWARRIOR+RACE_WARRIOR) then
		Duel.Hint(HINT_CARD,0,m)
		Duel.SetChainLimitTillChainEnd(cm.chainlimit)
	end
end
function cm.chainlimit(e,rp,tp)
	return not (rp~=tp and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:IsActiveType(TYPE_TRAP))
end