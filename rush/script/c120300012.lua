local cm,m=GetID()
cm.name="月力吊雪貂"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.confilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,5,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(1-tp,2)
		and Duel.IsExistingMatchingCard(cm.confilter,tp,0,LOCATION_GRAVE,5,nil)
		and RD.IsPlayerNoDrawInThisMain(tp) then
		RD.CanDraw(aux.Stringid(m,1),tp,2,true)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotActivateEffect(e,aux.Stringid(m,2),cm.aclimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not (tc:IsAttribute(ATTRIBUTE_EARTH) and tc:IsRace(RACE_GALAXY))
end