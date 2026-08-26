local cm,m=GetID()
local list={120294018}
cm.name="死灵女仆马车"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckBottomToGraveAndExists(tp,1) then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsRace(RACE_ZOMBIE) and tc:IsLocation(LOCATION_GRAVE)
			and Duel.GetMZoneCount(tp)>0 and RD.IsCanBeSpecialSummoned(tc,e,tp,POS_FACEUP)
			and Duel.SelectEffectYesNo(tp,tc,aux.Stringid(m,1)) then
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
				RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
			end
		end
	end
end