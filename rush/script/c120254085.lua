local cm,m=GetID()
cm.name="虚空噬骸兵晨星锤"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,cm.condition,nil,cm.target)
	--Double Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil)
end
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end