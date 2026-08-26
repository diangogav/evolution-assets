local cm,m=GetID()
local list={120109067}
cm.name="水晶占卜师"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.confilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_SPELLCASTER)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsFlipMainPhase(c)
		or Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,c)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 then return false end
		local g=Duel.GetDecktopGroup(tp,2)
		return g:IsExists(Card.IsAbleToHand,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 then
		local sg=RD.RevealDeckTopAndSelect(tp,2,HINTMSG_ATOHAND,aux.TRUE,1,1)
		local tc=sg:GetFirst()
		if tc then
			Duel.DisableShuffleCheck()
			if tc:IsAbleToHand() then
				RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
				Duel.ShuffleHand(tp)
			else
				Duel.SendtoGrave(sg,REASON_RULE)
			end
		end
		RD.SendDeckTopToBottom(tp,1)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,1),m,tp,list[1])
end