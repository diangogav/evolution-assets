--黄泉ガエル
--Treeborn Frog (pre-errata, Edison 2010)
--Based on the modern base script (c12538374.lua) with the single 2010 delta
--per edisonformat.com functional-errata + yugipedia Card_Errata (SOI-EN025):
--  "[Trigger] has no 'once per turn' restriction" (BOTH schools agree) — the
--  DUSA 2017 errata added "Once per turn"; this copy simply drops the
--  SetCountLimit(1). If the frog leaves the GY and returns, or the revival
--  whiffs, it can trigger again in the same Standby Phase (the classic 2010
--  loop).
--NOT deltas (kept verbatim from the modern script):
--  - The spell/trap gate: activation condition AND resolution re-check (a
--    spent chained spell still on the field whiffs the summon).
--  - The face-up "Treeborn Frog" block (a face-down copy has no name in
--    either era). IsCode(12538374) matches this copy too via its alias.
--This copy replaces the broken 511002980 wiring (file without the c prefix,
--cdb alias=0, both codes active in the lflist).
function c910003008.initial_effect(c)
	--Special Summon. Modeled as QUICK_O at EVENT_FREE_CHAIN (gated to the
	--owner's Standby Phase, open game state) instead of the modern
	--TRIGGER_O phase event: the core's phase-event bookkeeping spends a
	--card's optional phase trigger on activation even when the activation
	--is NEGATED, which would break the era ruling that a negated Treeborn
	--can activate again in the same Standby Phase (the Royal Oppression
	--war). A free-chain window re-evaluates every open state, so the
	--re-offer comes back for free.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12538374,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c910003008.condition)
	e1:SetTarget(c910003008.target)
	e1:SetOperation(c910003008.operation)
	c:RegisterEffect(e1)
end
function c910003008.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) or (c:IsCode(12538374) and c:IsFaceup())
end
function c910003008.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetCurrentPhase()==PHASE_STANDBY
		and Duel.GetCurrentChain()==0
		and not Duel.IsExistingMatchingCard(c910003008.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c910003008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c910003008.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c910003008.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(c910003008.filter2,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
