local cm,m=GetID()
local list={120294057,120294058}
cm.name="狮子的依代"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.filter(c)
	return c:IsCode(list[1],list[2]) and c:IsAbleToHand()
end
function cm.check(g)
	return g:GetClassCount(Card.GetCode)==g:GetCount()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	local sg,g=RD.RevealDeckTopAndCanSelectGroup(tp,4,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.filter,cm.check,1,2)
	if sg:GetCount()>0 then
		Duel.DisableShuffleCheck()
		RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		Duel.ShuffleHand(tp)
	end
	local ct=g:GetCount()
	if ct>0 then
		Duel.SortDecktop(tp,tp,ct)
		RD.SendDeckTopToBottom(tp,ct)
	end
end