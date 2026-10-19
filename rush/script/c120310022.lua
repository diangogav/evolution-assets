local cm,m=GetID()
local list={120000012,120310022}
cm.name="绳之王剑"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end
--Union
function cm.filter(c)
	local g=c:GetEquipGroup()
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
		and not g:IsExists(Card.IsCode,1,nil,list[2])
end