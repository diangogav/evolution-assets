local cm,m=GetID()
cm.name="在风中飘荡的飞来物"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 then
		local sg,lg=RD.RevealDeckTopAndCanSelect(tp,5,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.filter,1,2)
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
		if sg:IsExists(Card.IsLocation,2,nil,LOCATION_HAND) then
			RD.SelectAndDoAction(HINTMSG_TOGRAVE,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil,function(g)
				RD.SendToGraveAndExists(g)
			end)
		end
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,2),RACE_ALL-RACE_SEASERPENT,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT))
end