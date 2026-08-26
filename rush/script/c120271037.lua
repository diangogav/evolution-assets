local cm,m=GetID()
local list={120196050}
cm.name="虚钢演机名优"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return ((c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and RD.IsDefense(c,500))
		or c:IsCode(list[1])) and c:IsAbleToGrave()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	local sg,g=RD.RevealDeckTopAndCanSelect(tp,4,aux.Stringid(m,1),HINTMSG_TOGRAVE,cm.filter,1,1)
	local draw=false
	if sg:GetCount()>0 then
		Duel.DisableShuffleCheck()
		if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
			draw=Duel.GetOperatedGroup():IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		end
	end
	local ct=g:GetCount()
	if ct>0 then
		Duel.SortDecktop(tp,tp,ct)
		RD.SendDeckTopToBottom(tp,ct)
	end
	if draw then
		RD.CanDraw(aux.Stringid(m,2),tp,1)
	end
end