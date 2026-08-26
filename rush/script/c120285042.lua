local cm,m=GetID()
local list={120285014,120285015}
cm.name="幻坏双姬 半长裤双龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Cannot To Hand & Deck & Extra
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Cannot To Hand & Deck & Extra
function cm.condition(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.target(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end