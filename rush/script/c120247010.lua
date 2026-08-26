local cm,m=GetID()
local list={120207007,120247002}
cm.name="鹰身女妖的宠物龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Atk Up
function cm.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function cm.atkval(e,c)
	local atk1=Duel.GetMatchingGroupCount(cm.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil,list[1])*300
	local atk2=Duel.GetMatchingGroupCount(cm.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil,list[2])*900
	return atk1+atk2
end