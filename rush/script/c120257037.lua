local cm,m=GetID()
local list={120257001}
cm.name="高天贯通巨星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.prctg)
	c:RegisterEffect(e1)
	--Cannot Be Fusion Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(cm.fuscon)
	e2:SetValue(cm.fuslimit)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelBelow(8) and c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
--Pierce
function cm.prctg(e,c)
	return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
--Cannot Be Fusion Material
function cm.fuscon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end