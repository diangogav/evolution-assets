local cm,m=GetID()
local list={120244011}
cm.name="名流剑·死亡狂野剑"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(cm.prctg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Fusion Code
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ADD_FUSION_CODE)
	e4:SetCondition(cm.fuscon)
	e4:SetValue(list[1])
	c:RegisterEffect(e4)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
--Pierce
function cm.prctg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end
--Fusion Code
function cm.fusfilter(c)
	return c:IsCode(list[1])
end
function cm.fuscon(e)
	return Duel.IsExistingMatchingCard(cm.fusfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end