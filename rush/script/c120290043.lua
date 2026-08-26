local cm,m=GetID()
cm.name="乐姬的代演"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.exfilter1(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
function cm.exfilter2(c)
	return c:IsType(TYPE_MONSTER) and not cm.exfilter1(c)
end
function cm.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	RD.TargetDiscardDeck(tp,3)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.DiscardDeck()~=0 and Duel.IsExistingMatchingCard(cm.exfilter1,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(cm.exfilter2,tp,LOCATION_GRAVE,0,1,nil) then
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP_DEFENSE,true)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR))
end