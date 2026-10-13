local cm,m=GetID()
local list={120257008}
cm.name="穿越侍·高天海牛侍 主宰新星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Cannot To Hand & Deck & Extra
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e2)
	--Attribute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelBelow(8) and c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
