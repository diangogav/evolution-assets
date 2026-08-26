local cm,m=GetID()
local list={120208002}
cm.name="银河舰短剑"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	RD.RegisterEquipEffect(c,cm.condition,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevel(7,8)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,0,LOCATION_MZONE,1,nil)
end
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_GALAXY)
end
--Atk Up
function cm.upfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function cm.upval(e,c)
	local atk=Duel.GetMatchingGroupCount(cm.upfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*300
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsCode(list[1]) then atk=atk+1000 end
	return atk
end