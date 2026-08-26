local cm,m=GetID()
cm.name="双人单车机人"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter,cm.matfilter)
	--Direct Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_MACHINE)
		and (not sg or sg:FilterCount(aux.TRUE,c)==0
		or sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end