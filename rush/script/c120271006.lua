local cm,m=GetID()
local list={120271004,120271008,120271007}
cm.name="古代的机械强兵"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	-- Decrease Tribute
	RD.DecreaseSummonTribute(c,cm.sumcon,0x1)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.atkcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- Cannot Activate
	local e2=RD.ContinuousAttackNotChainTrap(c)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
-- Decrease Tribute
function cm.confilter(c)
	return c:IsFaceup() and (RD.IsLegendCode(c,list[1]) or c:IsCode(list[2],list[3]))
end
function cm.sumcon(e)
	return Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--Atk Up
function cm.atkcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end