local cm,m=GetID()
local list={120231024}
cm.name="嵌合超载龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedureRep(c,true,true,cm.matfilter,1,63,list[1])
	-- Fusion Flag
	RD.CreateFusionSummonFlag(c,20278001)
	--Base Atk & Def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	--Multiple Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(cm.atkval)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e3)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c,fc,sub)
	return c:IsRace(RACE_MACHINE)
end
--Base Atk & Def
function cm.adval(e)
	local c=e:GetHandler()
	if c:GetFlagEffect(20278001)~=0 then
		return c:GetMaterialCount()*800
	else
		return 0
	end
end
--Multiple Attack
function cm.atkval(e)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	if c:GetFlagEffect(20278001)~=0 and ct>1 then
		return ct-1
	else
		return 0
	end
end