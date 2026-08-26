local cm,m=GetID()
cm.name="名流释放"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
function cm.costfilter(c)
	if c:IsOnField() then
		return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToDeckOrExtraAsCost()
	else
		return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToDeckOrExtraAsCost()
	end
end
function cm.filter(c)
	return c:IsAttackPos() and c:IsAbleToHand()
end
function cm.costcheck(g)
	if g:GetClassCount(Card.GetLocation)~=1 then return false end
	if g:IsExists(Card.IsOnField,1,nil) then return g:GetCount()==1 end
	return g:GetCount()==4
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
cm.cost=RD.CostSendGroupToDeckSort(cm.costfilter,cm.costcheck,LOCATION_ONFIELD+LOCATION_GRAVE,1,4,false,SEQ_DECKSHUFFLE,false,true)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_RTOHAND,cm.filter,tp,0,LOCATION_MZONE,1,3,nil,function(g)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
end