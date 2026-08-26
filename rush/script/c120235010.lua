local cm,m=GetID()
cm.name="极奏之小提琴马赫毗奥"
function cm.initial_effect(c)
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
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function cm.atkval(e,c)
	local ct1=c:GetEquipCount()
	local ct2=Duel.GetMatchingGroupCount(cm.filter,c:GetControler(),0,LOCATION_MZONE,nil)
	return (ct1+ct2)*500
end