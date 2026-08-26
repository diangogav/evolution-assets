local cm,m=GetID()
local list={120196044}
cm.name="深龙的契约者"
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
	e1:SetTarget(cm.target)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Cannot Change Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.target)
	e2:SetValue(cm.posval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsFusionType(TYPE_EFFECT) and c:IsLevelBelow(8) and c:IsFusionAttribute(ATTRIBUTE_WATER)
end
--Atk Up
function cm.target(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttribute(ATTRIBUTE_WATER)
end
--Cannot Change Position
function cm.posval(e,re,r,rp)
	return re and r&REASON_EFFECT~=0 and rp~=e:GetHandlerPlayer()
end