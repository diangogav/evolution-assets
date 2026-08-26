local cm,m=GetID()
cm.name="超魔轨道 大霸道王［L］"
function cm.initial_effect(c)
	--To Deck (Normal)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
	--To Deck (MaximumMode)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(m,2))
	e2:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_XMATERIAL)
	e2:SetLabel(m)
	c:RegisterEffect(e2)
end
--To Deck
function cm.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	if RD.IsMaximumMode(e:GetHandler()) then
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) and RD.IsMaximumMode(c)
			and c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,3) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,1)) then
			if RD.SendToDeckAndExists(c,e,tp,REASON_EFFECT) then
				Duel.ShuffleDeck(tp)
				Duel.Draw(tp,3,REASON_EFFECT)
			end
		end
	end)
end