local cm,m=GetID()
local list={120145014,120120042,120105014}
cm.name="火星心激情岩浆妈妈"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	RD.AddRitualProcedure(c)
	--Change Damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(cm.damval)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.uptg)
	e2:SetValue(1300)
	c:RegisterEffect(e2)
	--Atk Down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(cm.downtg)
	e3:SetValue(cm.downval)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Change Damage
function cm.damval(e,re,val,r,rp,rc)
	if re and re:GetHandler():IsCode(list[2]) and rp==e:GetOwnerPlayer() then
		Duel.Hint(HINT_CARD,0,m)
		return 700
	else
		return val
	end
end
--Atk Up
function cm.downfilter(c)
	return c:IsCode(list[2],list[3])
end
--Atk Down
function cm.uptg(e,c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.downtg(e,c)
	return c:IsFaceup()
end
function cm.downval(e)
	local g=Duel.GetMatchingGroup(cm.downfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)*-400
end