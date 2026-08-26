local cm,m=GetID()
local list={120205009}
cm.name="与神树的相会"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.thfilter1(c)
	return c:IsCode(list[1])
end
function cm.thfilter2(c)
	return c:IsType(TYPE_EFFECT) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PLANT)
end
function cm.thfilter(c)
	return (cm.thfilter1(c) or cm.thfilter2(c)) and c:IsAbleToHand()
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (cm.thfilter1(tc1) and cm.thfilter2(tc2))
		or (cm.thfilter1(tc2) and cm.thfilter2(tc1))
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	local sg,lg=RD.RevealDeckTopAndCanSelectGroup(tp,4,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.thfilter,cm.check,1,2)
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