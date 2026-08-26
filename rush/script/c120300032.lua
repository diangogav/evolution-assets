local cm,m=GetID()
local list={120222025}
cm.name="永恒虚空噬骸兵·镇魂鹰巨人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedureRep(c,true,true,cm.matfilter,1,63,list[1])
	--Cannot To Hand & Deck & Extra
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.econ)
	e1:SetValue(cm.efilter)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.condition)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c,fc,sub)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
--Cannot To Hand & Deck & Extra
function cm.econ(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.efilter(e,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
--Indes
function cm.condition(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterialCount()>=3
end
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)