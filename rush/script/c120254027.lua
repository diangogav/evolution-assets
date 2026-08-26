local cm,m=GetID()
cm.name="引力冠视小爱"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	Duel.ConfirmDecktop(tp,5)
	local g1=Duel.GetDecktopGroup(tp,5)
	local g2=g1:Filter(cm.filter,nil)
	g1:Sub(g2)
	local ct1=g1:GetCount()
	local ct2=g2:GetCount()
	if ct1==0 then
		--All top
		Duel.SortDecktop(tp,tp,ct2)
	elseif ct2==0 then
		--All bottom
		Duel.SortDecktop(tp,tp,ct1)
		RD.SendDeckTopToBottom(tp,ct1)
	else
		g2:ForEach(function(tc)
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		end)
		Duel.SortDecktop(tp,tp,ct2)
		g1:ForEach(function(tc)
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		end)
		Duel.SortDecktop(tp,tp,ct1)
		RD.SendDeckTopToBottom(tp,ct1)
	end
	if ct2>3 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end