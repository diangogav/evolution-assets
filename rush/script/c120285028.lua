local cm,m=GetID()
cm.name="永远之体光摄手"
function cm.initial_effect(c)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.filter(c)
	return c:IsAbleToDeck()
end
function cm.thfilter(c)
	return c:IsLevel(9) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_GRAVE,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,0,LOCATION_GRAVE,1,1,nil,function(g)
		if RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)~=0
			and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 then
			local sg,lg=RD.RevealDeckTopAndCanSelect(tp,4,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.thfilter,1,1)
			if sg:GetCount()>0 then
				Duel.DisableShuffleCheck()
				RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
				Duel.ShuffleHand(tp)
			end
			local ct=lg:GetCount()
			if ct>0 then
				Duel.SortDecktop(tp,tp,ct)
				RD.SendDeckTopToBottom(tp,ct)
			end
		end
	end)
end