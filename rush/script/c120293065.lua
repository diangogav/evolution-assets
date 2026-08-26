local cm,m=GetID()
cm.name="传说系谱的魔术师"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Fake Legend
	RD.EnableFakeLegend(c,LOCATION_GRAVE)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Cannot Change Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.posval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Cannot Change Position
function cm.posval(e,re,r,rp)
	return re and r&REASON_EFFECT~=0 and rp~=e:GetHandlerPlayer()
end