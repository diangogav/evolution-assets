local cm,m=GetID()
cm.name="魔导书弃却"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)) or c:IsType(TYPE_SPELL)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,4)
	if g:GetCount()==0 then return end
	Duel.ConfirmDecktop(tp,4)
	local sg=g:Filter(cm.filter,nil)
	local draw=false
	if sg:GetCount()>0 then
		Duel.DisableShuffleCheck()
		if Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)~=0 then
			g:Sub(sg)
			local og=Duel.GetOperatedGroup()
			draw=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==4
		end
	end
	if g:GetCount()>0 then
		Duel.ShuffleDeck(tp)
	end
	if draw then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end