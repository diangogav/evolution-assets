local cm,m=GetID()
local list={120239013,120239015}
cm.name="深渊龙神 深渊波塞德拉"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Maximum Summon
	RD.AddMaximumProcedure(c,4000,list[1],list[2])
	--Cannot Activate
	local e1=RD.ContinuousAttackNotChainTrap(c)
	e1:SetCondition(cm.actcon)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.indcon)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Cannot Activate
function cm.confilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.actcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
function cm.indcon(e)
	return cm.actcon(e,e:GetHandlerPlayer()) and RD.MaximumMode(e)
end