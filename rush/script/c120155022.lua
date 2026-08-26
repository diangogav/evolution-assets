local cm,m=GetID()
local list={120155021,120155023}
cm.name="幻龙重骑 超斗轮挖掘鳞虫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Maximum Summon
	RD.AddMaximumProcedure(c,3500,list[1],list[2])
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.MaximumMode)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)