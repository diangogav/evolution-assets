local cm,m=GetID()
local list={120271004,120271007}
cm.name="古代的机械变速"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and not RD.IsMaximumMode(c)
		and c:GetBaseAttack()==c:GetBaseDefense()
		and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
--Atk Up
function cm.upfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function cm.upval(e,c)
	local atk=400
	local ec=e:GetHandler():GetEquipTarget()
	if RD.IsLegendCode(ec,list[1]) or ec:IsCode(list[2]) then atk=atk+600 end
	return atk
end