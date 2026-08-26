local cm,m=GetID()
local list={120205009}
cm.name="柳安猛男·块根"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	RD.RegisterUnionEffect(c,cm.filter,nil,cm.cost)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PLANT)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
--Atk Up
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.atkval(e,c)
	if Duel.IsExistingMatchingCard(cm.exfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) then
		return 1600
	else
		return 800
	end
end