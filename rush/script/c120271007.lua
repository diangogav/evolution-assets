local cm,m=GetID()
cm.name="古代的机械兽"
function cm.initial_effect(c)
	RD.CannotSpecialSummon(c)
	-- Cannot Activate
	local e1=RD.ContinuousAttackNotChainTrap(c)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end