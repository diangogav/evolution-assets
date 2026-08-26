local cm,m=GetID()
cm.name="双焰魔天 夜月天魔"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Atk & Def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.downtg)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Cannot Activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.actcon)
	e3:SetOperation(cm.actlimit)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Atk & Def
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function cm.condition(e)
	return Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function cm.downtg(e,c)
	return c:IsFaceup()
end
--Cannot Activate
function cm.actfilter(c)
	return c:IsType(TYPE_MAXIMUM)
end
function cm.actcon(e)
	return Duel.IsExistingMatchingCard(cm.actfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil)
end
function cm.actlimit(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	if c:IsFaceup() and c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_FIRE) then
		Duel.Hint(HINT_CARD,0,m)
		Duel.SetChainLimitTillChainEnd(cm.chainlimit)
	end
end
function cm.chainlimit(e,rp,tp)
	return not (rp~=tp and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:IsActiveType(TYPE_TRAP))
end