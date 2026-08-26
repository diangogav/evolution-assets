local cm,m=GetID()
cm.name="昆遁忍虫 迷网之蜘蛛"
function cm.initial_effect(c)
	--Cannot Be Battle Target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetValue(cm.target)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Cannot Be Battle Target
function cm.confilter1(c)
	return c:IsFaceup() and c:GetOriginalRace()==RACE_INSECT
end
function cm.confilter2(c)
	return c:IsFaceup() and c:GetOriginalRace()~=RACE_INSECT
end
function cm.condition(e)
	local tp=e:GetHandlerPlayer()
	return not RD.IsAttacking(e)
		and Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_MZONE,0,1,nil)
		and not Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_MZONE,0,1,nil)
end
function cm.target(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local sg=g:GetMaxGroup(Card.GetAttack)
	return not sg:IsContains(c)
end