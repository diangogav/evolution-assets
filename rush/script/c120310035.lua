local cm,m=GetID()
local list={120309058,120310035}
cm.name="开朗的天使 米迦"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.thfilter(c)
	return ((c:IsAttack(900) and RD.IsDefense(c,100)) or c:IsCode(list[1])) and c:IsAbleToHand()
end
cm.cost=RD.CostSendDeckTopToGrave(2)
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetClassCount(Card.GetRace)>=2
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		g:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
			Duel.BreakEffect()
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[2])
end