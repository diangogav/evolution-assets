local cm,m=GetID()
local list={120310066,120310021,120310022}
cm.name="黑刹的王 绳"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2],list[3])
	--Union Fusion
	RD.EnableUnionFusion(c,aux.Stringid(m,0))
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.target)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.target)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Pierce
function cm.target(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
