local cm,m=GetID()
cm.name="接合科技B赛车"
function cm.initial_effect(c)
	--Union
	RD.RegisterUnionEffect(c,cm.filter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--Cannot Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(aux.IsUnionState)
	e2:SetOperation(cm.actlimit)
	c:RegisterEffect(e2)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
--Cannot Activate
function cm.actlimit(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	if c:IsFaceup() and e:GetHandler():GetEquipTarget()==c then
		Duel.Hint(HINT_CARD,0,m)
		Duel.SetChainLimitTillChainEnd(cm.chainlimit)
	end
end
function cm.chainlimit(e,rp,tp)
	return not (e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:IsActiveType(TYPE_TRAP))
end