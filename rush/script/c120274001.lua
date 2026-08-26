local cm,m=GetID()
cm.name="真红眼极炎龙［L］"
function cm.initial_effect(c)
	--Indes (Normal)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Indes (MaximumMode)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	c:RegisterEffect(e2)
	--Damage
	local e3=RD.ContinuousBattleDestroyToGrave(c,cm.damcon,cm.damop,false)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_CONTINUOUS)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
--Damage
function cm.damcon(e,tp,eg,ep,ev,re,r,rp)
	return RD.MaximumMode(e)
end
function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Damage(1-tp,2400,REASON_EFFECT)
end