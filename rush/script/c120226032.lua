local cm,m=GetID()
cm.name="火降烧壁"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_PYRO)
end
function cm.exfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsLocation(LOCATION_GRAVE)
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
		and tc:IsControler(1-tp) and tc:IsLevelBelow(8)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SendDeckTopToGraveAndExists(tp,3) then
		local atk=Duel.GetOperatedGroup():FilterCount(cm.exfilter,nil)*-400
		local g=Duel.GetMatchingGroup(cm.atkfilter,tp,0,LOCATION_MZONE,nil)
		if atk==0 or g:GetCount()==0 then return end
		Duel.BreakEffect()
		g:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end