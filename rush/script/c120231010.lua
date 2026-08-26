local cm,m=GetID()
cm.name="焰魔神 蝇光蛇三魔［L］"
function cm.initial_effect(c)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(RD.MaximumMode)
	e1:SetValue(cm.indes)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Indes
function cm.indes(e,c)
	return c:IsType(TYPE_NORMAL)
end