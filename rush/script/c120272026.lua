local cm,m=GetID()
cm.name="爱之天人"
function cm.initial_effect(c)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter(c)
	return not c:IsLevel(4) and c:IsRace(RACE_FAIRY) and c:IsAttack(0) and c:IsAbleToHand()
end
cm.cost=RD.CostPayLP(500)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	local sg,g=RD.RevealDeckTopAndCanSelect(tp,4,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.thfilter,1,1)
	local rec=false
	if sg:GetCount()>0 then
		Duel.DisableShuffleCheck()
		rec=RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT) and sg:GetFirst():IsAttribute(ATTRIBUTE_LIGHT)
		Duel.ShuffleHand(tp)
	end
	local ct=g:GetCount()
	if ct>0 then
		Duel.SortDecktop(tp,tp,ct)
		RD.SendDeckTopToBottom(tp,ct)
	end
	if rec and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end