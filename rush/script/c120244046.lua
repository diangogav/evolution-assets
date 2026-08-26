local cm,m=GetID()
cm.name="上级冲击"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter1(c)
	return c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function cm.filter2(c,g)
	return c:IsFaceup() and c:IsLevelAbove(1)
		and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,g:GetCount())
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,0,LOCATION_MZONE,1,nil,g) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_HAND,0,nil)
	local filter=RD.Filter(cm.filter2,g)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
		local tc=sg:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local mg=g:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,g:GetCount())
		if Duel.SendtoGrave(mg,REASON_EFFECT)~=0 and RD.IsCanAttachOpponentTribute(tc,tp,20244046) then
			RD.AttachOpponentTribute(e,tc,20244046,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,RESET_PHASE+PHASE_END)
		end
	end)
end