local cm,m=GetID()
cm.name="超银河王 道皆通银河舰［R］"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(m)
	e1:SetCondition(RD.MaximumMode)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.filter1(c)
	return c:IsLevelAbove(1) and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function cm.filter2(c,g)
	return c:IsFaceup() and c:IsLevelAbove(1)
		and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,g:GetCount())
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,0,LOCATION_MZONE,1,nil,g) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_HAND,0,nil)
	local filter=RD.Filter(cm.filter2,g)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
		local c=e:GetHandler()
		local tc=sg:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local mg=g:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,g:GetCount())
		if Duel.SendtoGrave(mg,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,1)) then
			RD.AttachAtkDef(e,c,tc:GetAttack(),0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end