local cm,m=GetID()
local list={120263008,120263007}
cm.name="元素英雄 火焰翼侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Only Fusion Summon
	RD.OnlyFusionSummon(c)
	--Damage
	local e1=RD.ContinuousBattleDestroyToGrave(c,nil,cm.damop)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Damage
function cm.damop(e,tp,eg,ep,ev,re,r,rp,tc)
	if tc then
		local dam=RD.GetBaseAttackOnDestroy(tc)
		Duel.Hint(HINT_CARD,0,m)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end