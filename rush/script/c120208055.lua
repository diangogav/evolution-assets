local cm,m=GetID()
cm.name="羊界-墓地积怨念"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.thfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	return Duel.GetAttacker():IsControler(1-tp)
		and c and c:IsControler(tp) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_BEAST)
end
cm.cost=RD.CostSendDeckTopToGrave(4,nil,function(g)
	local cg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	cg:KeepAlive()
	return cg
end)
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	if c and c:IsRelateToBattle() and c:IsFaceup() then
		RD.AttachAtkDef(e,c,-2000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local g=e:GetLabelObject()
		if g:FilterCount(cm.thfilter,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			local sg=g:FilterSelect(tp,cm.thfilter,1,4,nil)
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end
		g:DeleteGroup()
	end
end