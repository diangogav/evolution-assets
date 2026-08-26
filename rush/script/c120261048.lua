local cm,m=GetID()
local list={120264005}
cm.name="暗物质人偶·谜团机偶"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[1])
	-- Fusion Flag
	RD.CreateFusionSummonFlag(c,20261048)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Material Check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetLabelObject(e1)
	e2:SetValue(cm.check)
	c:RegisterEffect(e2)
	--Indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.indcon)
	e3:SetValue(cm.indval)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e3)
end
--Material Check
function cm.check(e,c)
	local atk=0
	local g=c:GetMaterial()
	g:ForEach(function(tc)
		atk=atk+RD.GetBaseAttackOnTribute(tc)
	end)
	if atk>0 then
		e:GetLabelObject():SetLabel(atk)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
--Atk Up
function cm.atkval(e,c)
	if c:GetFlagEffect(20261048)~=0 then return e:GetLabel() else return 0 end
end
--Indes
function cm.indcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)