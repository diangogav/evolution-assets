local cm,m=GetID()
cm.name="QWERTY键盘刃"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
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
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
--Atk Up
function cm.upfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function cm.upval(e,c)
	return Duel.GetMatchingGroupCount(cm.upfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*200
end
--Pierce
function cm.prctg(e,c)
	return c==e:GetHandler():GetEquipTarget() and c:IsAttribute(ATTRIBUTE_DARK)
end