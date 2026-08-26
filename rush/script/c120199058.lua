local cm,m=GetID()
local list={120145052,120145050}
cm.name="海豚反击"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsCode(list[1],list[2]) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	return Duel.GetAttacker():IsControler(1-tp)
		and c and c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local mg=g:GetMaxGroup(Card.GetAttack)
	local sg=nil
	if mg:GetCount()>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		sg=mg:Select(tp,1,1,nil)
	else
		sg=mg
	end
	Duel.HintSelection(sg)
	if Duel.Destroy(sg,REASON_EFFECT)~=0 and Duel.IsPlayerCanDraw(tp,1) then
		local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsCode(list[1],list[2]) then
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
		Duel.ShuffleHand(tp)
	end
end