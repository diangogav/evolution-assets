local cm,m=GetID()
local list={120145000}
cm.name="恶魔显现"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.uptg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,RD.EnableChangeCode(c,list[1],LOCATION_MZONE))
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
--Atk Up
function cm.uptg(e,c)
	return c:IsFaceup() and RD.IsLegendCode(c,list[1])
end