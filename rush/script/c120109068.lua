local cm,m=GetID()
cm.name="云海龙 棘颊双锯龙"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Union
	RD.RegisterUnionEffect(c,aux.TRUE,nil,cm.cost)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(aux.IsUnionState)
	e1:SetTarget(cm.indtg)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
--Union
cm.cost=RD.CostSendDeckTopToGrave(2)
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c~=e:GetHandler()
end