local cm,m=GetID()
local list={120249049}
cm.name="化学化火山盾"
function cm.initial_effect(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(cm.upval)
	c:RegisterEffect(e2)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
--Atk Up
function cm.upfilter(c)
	return c:IsType(TYPE_MAXIMUM) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER)
end
function cm.upval(e,c)
	return Duel.GetMatchingGroupCount(cm.upfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*300
end