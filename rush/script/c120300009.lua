local cm,m=GetID()
local list={120255004,120300008}
cm.name="冥迹之卡迪"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spcon,nil,nil,nil,POS_FACEUP_DEFENSE)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsFaceup() and c:IsCode(list[1],list[2])
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
--Discard Deck
function cm.tdfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToDeck()
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(1-tp,FLAG_MAX_ATTACK_TWICE_NEXT_TURN)==0 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1,e2=RD.CreateLimitAttackCountEffect(e,aux.Stringid(m,2),2,tp,0,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e2:SetCondition(cm.atkcon)
	Duel.RegisterFlagEffect(1-tp,FLAG_MAX_ATTACK_TWICE_NEXT_TURN,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
	RD.CanSelectAndDoAction(aux.Stringid(m,3),HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil,function(g)
		RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
	end)
end
function cm.atkcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end