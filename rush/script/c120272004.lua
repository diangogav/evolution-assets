local cm,m=GetID()
cm.name="化学火山化火巨灵"
function cm.initial_effect(c)
	RD.CreateAdvanceSummonFlag(c,20272004)
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
	if c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER) then
		return c:GetOriginalLevel()*400
	else
		return 0
	end
end
--Atk Up
function cm.atkval(e,c)
	if c:GetFlagEffect(20272004)~=0 then return e:GetLabel() else return 0 end
end