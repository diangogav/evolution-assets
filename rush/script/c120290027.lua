local cm,m=GetID()
cm.name="巧阵的奇迹魔"
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
	return c:IsLevel(9) and c:IsRace(RACE_FIEND) and RD.IsDefense(c,2000) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 then
		local sg,lg=RD.RevealDeckTopAndCanSelect(tp,5,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.thfilter,1,1)
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