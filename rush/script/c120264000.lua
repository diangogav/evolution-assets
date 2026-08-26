local cm,m=GetID()
local list={120263001,120263005}
cm.name="元素英雄 闪光火焰翼侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Only Fusion Summon
	RD.OnlyFusionSummon(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Damage
	local e2=RD.ContinuousBattleDestroyToGrave(c,nil,cm.damop)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Up
function cm.filter(c)
	return c:IsRace(RACE_WARRIOR)
end
function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(cm.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end
--Damage
function cm.damop(e,tp,eg,ep,ev,re,r,rp,tc)
	if tc then
		local dam=RD.GetBaseAttackOnDestroy(tc)
		Duel.Hint(HINT_CARD,0,m)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end