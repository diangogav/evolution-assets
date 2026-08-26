local cm,m=GetID()
local list={120260009}
cm.name="深空宇宙世界树龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedureSP(c,true,true,cm.matfilter,cm.check,2,3)
	RD.SetFusionMaterial(c,{list[1]},3,3)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--Atk Down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(cm.downtg)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Fusion Material
function cm.matfilter(c,fc,sub)
	return c:IsFusionCode(list[1]) or (sub and c:CheckFusionSubstitute(fc))
end
function cm.exfilter(c)
	return RD.IsCanBeDoubleFusionMaterial(c,120260007)
end
function cm.check(g,tp,fc,chkf)
	return g:GetCount()==3 or g:IsExists(cm.exfilter,1,nil)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
--Atk Down
function cm.downtg(e,c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end