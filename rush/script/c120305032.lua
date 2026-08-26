local cm,m=GetID()
local list={120199047}
cm.name="再见武器-阿修罗副打"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Union
	RD.RegisterUnionEffect(c,cm.filter,cm.condition,nil,nil,cm.limit)
	--Attack All
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
--Union
function cm.filter(c)
	return c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)
end
function cm.confilter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function cm.limit(e,tp,eg,ep,ev,re,r,rp)
	RD.CreateLimitAttackCountEffect(e,aux.Stringid(m,1),3,tp,1,0,RESET_PHASE+PHASE_END)
end