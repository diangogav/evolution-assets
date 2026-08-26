local cm,m=GetID()
cm.name="梦中之幼虫"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,false,cm.matfilter,cm.matfilter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.uptg)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	--Cannot To Hand & Deck & Extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(cm.condition)
	e2:SetTarget(cm.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelBelow(6) and c:IsRace(RACE_INSECT) and c:IsFusionType(TYPE_EFFECT)
end
--Atk Up
function cm.uptg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
--Cannot To Hand & Deck & Extra
function cm.condition(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.target(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end