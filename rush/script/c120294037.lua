local cm,m=GetID()
cm.name="罗蕾莱河女"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.exfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsLevel(3,4) and c:IsAttackBelow(1500)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,3) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.exfilter,tp,0,LOCATION_GRAVE,1,1,nil,function(g)
			local tc=g:GetFirst()
			local actlimit=function(e,re,tp)
				return RD.IsSameOriginalCode(re:GetHandler(),tc)
			end
			RD.CreateCannotActivateEffect(e,aux.Stringid(m,3),actlimit,tp,1,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end)
	end
end