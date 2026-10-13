local cm,m=GetID()
local list={120263008,120263007,120311026,120307014}
cm.name="邪心英雄 业火翼魔"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Special Summon Condition
	RD.OnlySpecialSummonByEffect(c,cm.splimit)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Damage
	local e2=RD.ContinuousBattleDestroyToGrave(c,nil,cm.damop)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Special Summon Condition
function cm.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(list[3],list[4])
end
--Damage
function cm.damop(e,tp,eg,ep,ev,re,r,rp,tc)
	if tc then
		local atk=RD.GetBaseAttackOnDestroy(tc)
		local def=RD.GetBaseDefenseOnDestroy(tc)
		local dam=math.max(atk,def)
		Duel.Hint(HINT_CARD,0,m)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end