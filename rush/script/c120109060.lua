local cm,m=GetID()
local list={120227012,120222025}
cm.name="虚空噬骸兵·白骑士"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.thfilter(c)
	return (c:IsCode(list[2]) or (c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_GALAXY))) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9 and RD.IsCanChangeCode(e:GetHandler(),list[1])
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
		local sg,g=RD.RevealDeckTopAndCanSelect(tp,3,aux.Stringid(m,1),HINTMSG_ATOHAND,cm.thfilter,1,1)
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
end