local cm,m=GetID()
cm.name="直奔目标钓鱼喵"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.spfilter1(c,e,tp)
	return c:IsLevelBelow(6) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
function cm.spfilter2(c,e,tp)
	return c:IsLevelAbove(1) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) or Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_NONE,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=RD.SelectOption(tp,
		{Duel.IsPlayerCanDiscardDeck(tp,2),aux.Stringid(m,1)},
		{Duel.IsPlayerCanDiscardDeck(1-tp,2),aux.Stringid(m,2)})
	local res=false
	if op==1 then
		res=RD.SendDeckTopToGraveAndExists(tp,2)
	else
		res=RD.SendDeckTopToGraveAndExists(1-tp,2)
	end
	if res then
		local spfilter=cm.spfilter1
		if Duel.GetTurnCount()==2 then
			spfilter=cm.spfilter2
		end
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,3),aux.NecroValleyFilter(spfilter),tp,0,LOCATION_GRAVE,1,1,nil,e,POS_FACEUP_DEFENSE,true)
	end
end