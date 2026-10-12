local cm,m=GetID()
local list={120213010}
cm.name="接合科技究极战士"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter,cm.matfilter)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Material Check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(cm.valcheck)
	c:RegisterEffect(e3)
	--Fusion Success
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetLabelObject(e3)
	e4:SetCondition(cm.regcon)
	e4:SetOperation(cm.regop)
	c:RegisterEffect(e4)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.condition(e)
	return e:GetHandler():GetFlagEffect(20213010)~=0
end
--Material Check
function cm.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_MAXIMUM+TYPE_UNION) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
--Fusion Success
function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabelObject():GetLabel()==1
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(20213010,RESET_EVENT+RESETS_STANDARD,0,1)
end