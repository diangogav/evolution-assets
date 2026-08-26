local cm,m=GetID()
cm.name="古代的机械超巨人"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter,cm.matfilter,cm.matfilter)
	-- Fusion Flag
	RD.CreateFusionSummonFlag(c,20283030)
	-- Cannot Activate
	local e1=RD.ContinuousAttackNotChainTrap(c)
	--Attack Twice
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(cm.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Material Check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetLabelObject(e2)
	e3:SetValue(cm.check)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e2,e2)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return not RD.IsMaximumMode(c) and c:GetBaseAttack()==c:GetBaseDefense()
		and c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
--Material Check
function cm.exfilter(c)
	return c:GetOriginalLevel()==8
end
function cm.check(e,c)
	local g=c:GetMaterial()
	e:GetLabelObject():SetLabel(g:FilterCount(cm.exfilter,nil))
end
--Attack Twice
function cm.condition(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(20283030)~=0 and e:GetLabel()>=2
end