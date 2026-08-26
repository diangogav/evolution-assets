local cm,m=GetID()
local list={120239016,120239018}
cm.name="深渊海龙 深渊乌贼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Maximum Summon
	RD.AddMaximumProcedure(c,4000,list[1],list[2])
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.indcon)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Cannot Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(cm.actcon)
	e2:SetOperation(cm.actlimit)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
function cm.confilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.indcon(e)
	return not Duel.IsExistingMatchingCard(cm.confilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
--Cannot Activate
function cm.actcon(e,tp,eg,ep,ev,re,r,rp)
	return cm.indcon(e) and RD.MaximumMode(e)
end
function cm.actlimit(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.SetChainLimitTillChainEnd(cm.chainlimit)
end
function cm.chainlimit(e,rp,tp)
	return not (rp~=tp and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:IsActiveType(TYPE_TRAP))
end