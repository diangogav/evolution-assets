local cm,m=GetID()
local list={120130000}
cm.name="龙骑士 黑魔术师"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(cm.target)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,RD.EnableChangeCode(c,list[1],LOCATION_MZONE))
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsRace(RACE_DRAGON)
end
--Indes
function cm.target(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)