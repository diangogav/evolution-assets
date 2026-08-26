local cm,m=GetID()
local list={120105001}
cm.name="七星道附魔师"
function cm.initial_effect(c)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.filter(c)
	return c:IsFaceup() and not c:IsLevel(3) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
function cm.exfilter(c)
	return c:IsOriginalCodeRule(list[1]) and c:IsLocation(LOCATION_HAND)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_RTOHAND,cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT,cm.exfilter,1,nil) then
			RD.CanDraw(aux.Stringid(m,1),tp,1)
		end
	end)
end