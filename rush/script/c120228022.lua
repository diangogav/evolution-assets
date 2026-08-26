local cm,m=GetID()
cm.name="蓝草音乐偷窃者"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
cm.trival=RD.ValueDoubleTributeAttrRace(ATTRIBUTE_WIND,RACE_PSYCHO)
function cm.exfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsLocation(LOCATION_GRAVE)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and RD.IsCanAttachDoubleTribute(c,cm.trival)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,1,cm.exfilter,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
			RD.AttachDoubleTribute(e,g:GetFirst(),cm.trival,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end