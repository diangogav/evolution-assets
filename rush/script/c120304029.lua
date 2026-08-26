local cm,m=GetID()
local list={120196050}
cm.name="花牙点 绣球"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.confilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.filter(c)
	return (cm.filter1(c) or cm.filter2(c)) and c:IsAbleToHand()
end
function cm.filter1(c)
	return c:IsLevel(7) and c:IsRace(RACE_PLANT)
end
function cm.filter2(c)
	return c:IsCode(list[1])
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (cm.filter1(tc1) and cm.filter2(tc2)) or (cm.filter1(tc2) and cm.filter2(tc1))
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	local sg,g=RD.RevealDeckTopAndCanSelectGroup(tp,5,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.filter,cm.check,1,2)
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
	if sg:GetCount()==2 then
		RD.SelectAndDoAction(HINTMSG_TOGRAVE,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil,function(og)
			Duel.SendtoGrave(og,REASON_EFFECT)
		end)
	end
end