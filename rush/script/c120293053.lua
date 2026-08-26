local cm,m=GetID()
cm.name="惑精 水仙水星"
function cm.initial_effect(c)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_GALAXY) and c:IsAttack(900) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 then
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
end