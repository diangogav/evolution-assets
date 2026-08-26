local cm,m=GetID()
cm.name="古代的机械恐兽"
function cm.initial_effect(c)
	-- Decrease Tribute
	RD.DecreaseSummonTribute(c,cm.sumcon,0x1)
	-- Cannot Activate
	local e1=RD.ContinuousAttackNotChainTrap(c)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
-- Decrease Tribute
function cm.confilter(c)
	return c:IsFaceup() and RD.IsHasContinuousEffect(c)
		and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function cm.sumcon(e)
	return Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end