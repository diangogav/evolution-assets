local cm,m=GetID()
cm.name="猫牌货眼镜蛇"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
cm.trival=RD.ValueDoubleTributeAttrRace(ATTRIBUTE_DARK,RACE_SPELLCASTER)
function cm.exfilter(c)
	return c:IsLevelBelow(9) and c:IsAttackAbove(100) and c:IsLocation(LOCATION_GRAVE)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,1,cm.exfilter,1,nil) then
		local c=e:GetHandler()
		local tc=Duel.GetOperatedGroup():GetFirst()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			RD.AttachAtkDef(e,c,tc:GetAttack(),0,RESET_EVENT+RESETS_STANDARD)
		end
	end
end