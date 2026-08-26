local cm,m=GetID()
cm.name="电子界香料忍·肉豆蔻"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE)
end
--Discard Deck
function cm.filter(c,g)
	return g:IsContains(c) and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetDecktopGroup(tp,1)
	local g2=Duel.GetDecktopGroup(1-tp,1)
	g1:Merge(g2)
	Duel.DisableShuffleCheck()
	if Duel.SendtoGrave(g1,REASON_EFFECT)==0 then return end
	local filter=aux.NecroValleyFilter(RD.Filter(cm.filter,g1))
	RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_TODECK,filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,function(g)
		Duel.BreakEffect()
		RD.SendToDeckTopOrBottom(g,e,tp,REASON_EFFECT,aux.Stringid(m,3),aux.Stringid(m,4))
	end)
end