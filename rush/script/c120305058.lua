local cm,m=GetID()
local list={120305056,120305057}
cm.name="Z-金属履带"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(600)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
--Union
function cm.filter(c)
	return c:IsCode(list[1]) or c:IsCode(list[2])
		or ((aux.IsMaterialListCode(c,list[1]) or aux.IsMaterialListCode(c,list[2]))
		and c:IsType(TYPE_FUSION))
end