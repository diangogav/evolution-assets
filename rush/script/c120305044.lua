local cm,m=GetID()
local list={120241008}
cm.name="何者"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(2500)
	c:RegisterEffect(e1)
end
--Union
function cm.filter(c)
	return c:IsCode(list[1]) and c:GetUnionCount()==0
end