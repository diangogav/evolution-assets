local cm,m=GetID()
local list={120287003,120287001}
cm.name="杰拉之剑"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(cm.condition)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(cm.condition)
	e3:SetTarget(cm.prctg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
--Activate
function cm.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsCode(list[1],list[2])
end
--Pierce
function cm.prctg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end