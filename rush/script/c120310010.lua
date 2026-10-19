local cm,m=GetID()
local list={120310003}
cm.name="α版飞龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(1) and c:IsRace(RACE_DRAGON) and RD.IsDefense(c,1000)
		and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	local sg,g=RD.RevealDeckTopAndCanSelect(tp,5,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.filter,1,2)
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