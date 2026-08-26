local cm,m=GetID()
cm.name="银河舰既视龙"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.exfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsRace(RACE_GALAXY) and c:IsLocation(LOCATION_GRAVE)
end
function cm.thfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsLPAbove(1-tp,4000)
end
cm.cost=RD.CostSendSelfToGrave()
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,1,cm.exfilter,1,nil) then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and RD.IsCanBeSpecialSummoned(tc,e,tp,POS_FACEUP)
			and Duel.SelectEffectYesNo(tp,tc,aux.Stringid(m,1))
			and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
		end
	end
end