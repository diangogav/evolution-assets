local cm,m=GetID()
cm.name="看破之哈维"
function cm.initial_effect(c)
	--Confirm
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Confirm
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_FACEDOWN,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		Duel.ConfirmCards(tp,g)
		local tc=g:GetFirst()
		if tc:IsType(TYPE_MONSTER) and RD.IsDefenseAbove(tc,1500)
			and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end)
end