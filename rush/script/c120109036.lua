local cm,m=GetID()
local list={120209001}
cm.name="穿越侍·鱿鱼侍"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY) and c:IsLocation(LOCATION_GRAVE)
end
function cm.filter(c)
	return c:IsFaceup() and RD.IsCanAttachPierce(c)
end
function cm.posfilter(c,e,tp)
	return c:IsAttackPos() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,1,cm.exfilter,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.filter,tp,LOCATION_MZONE,0,1,3,nil,function(g)
			g:ForEach(function(tc)
				RD.AttachPierce(e,tc,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
			local filter=RD.Filter(cm.posfilter,e,tp)
			local mg=Duel.GetMatchingGroup(filter,tp,0,LOCATION_MZONE,nil)
			if g:IsExists(Card.IsCode,1,nil,list[1]) and mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,4)) then
				RD.ChangePosition(mg,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
			end
		end)
	end
end