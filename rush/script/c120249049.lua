local cm,m=GetID()
cm.name="化学化结构力"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(cm.indcon)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER)
end
--Atk Up
function cm.upval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetClassCount(Card.GetRace)*300
end
--Indes
function cm.indcon(e)
	return e:GetHandler():GetEquipTarget():IsType(TYPE_MAXIMUM)
end
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)