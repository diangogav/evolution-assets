local cm,m=GetID()
cm.name="等离子塑料模型 雷神俱-改造姬"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.atkcon)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Atk Up
function cm.atkcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.atkval(e,c)
	return c:GetLevel()*200
end