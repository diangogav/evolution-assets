local cm,m=GetID()
cm.name="伟大魔兽 加泽特"
function cm.initial_effect(c)
	RD.CreateAdvanceSummonFlag(c,20238019)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Material Check
	RD.AdvanceMaterialCheck(c,e1,cm.getter)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Material Check
function cm.getter(c)
	return RD.GetBaseAttackOnTribute(c)*2
end
--Atk Up
function cm.atkval(e,c)
	if c:GetFlagEffect(20238019)~=0 then return e:GetLabel() else return 0 end
end