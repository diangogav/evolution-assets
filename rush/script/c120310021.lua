local cm,m=GetID()
local list={120000012,120310021}
cm.name="绳之王冠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--Cannot To Hand & Deck & Extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e2:SetCondition(aux.IsUnionState)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e3)
end
--Union
function cm.filter(c)
	local g=c:GetEquipGroup()
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
		and not g:IsExists(Card.IsCode,1,nil,list[2])
end