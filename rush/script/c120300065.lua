local cm,m=GetID()
local list={120263032}
cm.name="元素英雄 金刃侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
		and Duel.IsExistingMatchingCard(cm.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end