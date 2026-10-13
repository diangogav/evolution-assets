local cm,m=GetID()
local list={120263032}
cm.name="元素英雄 荒野侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Cannot To Hand & Deck & Extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.efilter)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e3)
	--Atk Up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cm.condition)
	e4:SetValue(1000)
	c:RegisterEffect(e4)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,e4)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_TRAP,TYPE_TRAP,true)
--Cannot To Hand & Deck & Extra
function cm.efilter(e,re,r,rp)
	return re:IsActiveType(TYPE_TRAP)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
		and Duel.IsExistingMatchingCard(cm.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end