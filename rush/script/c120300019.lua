local cm,m=GetID()
local list={120300063}
cm.name="爱之天仙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.thfilter(c)
	return ((c:IsLevelAbove(7) and c:IsRace(RACE_FAIRY) and c:IsAttack(0))
		or c:IsCode(list[1])) and c:IsAbleToHand()
end
cm.cost=RD.CostSendHandOrFieldToGrave(Card.IsAbleToGraveAsCost,1,1,true)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,1800,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		if RD.IsSummonTurn(c) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
				RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
			end)
		end
	end
end