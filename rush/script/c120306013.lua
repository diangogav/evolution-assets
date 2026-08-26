local cm,m=GetID()
local list={120205009}
cm.name="柳安地图绘制员·常春藤"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	RD.RegisterUnionEffect(c,cm.filter,nil,cm.cost)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(cm.prctg)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Act Limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(cm.condition)
	e3:SetValue(cm.aclimit)
	c:RegisterEffect(e3)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PLANT)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
--Pierce
function cm.prctg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end
--Act Limit
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.condition(e)
	return aux.IsUnionState(e)
		and Duel.IsExistingMatchingCard(cm.exfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,2,nil)
end
function cm.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end