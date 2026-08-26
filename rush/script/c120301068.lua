local cm,m=GetID()
cm.name="等离子塑料模型 换装雷神俱-混合姬"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(cm.downtg)
	e1:SetValue(-600)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Down
function cm.downtg(e,c)
	return c:IsFaceup()
end