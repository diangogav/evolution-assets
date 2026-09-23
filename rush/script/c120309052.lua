local cm,m=GetID()
local list={CARD_CODE_FuSiGiNaKoBiTo,120309052}
cm.name="温柔的人类小姐"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.costfilter(c)
	return c:IsAbleToDeckOrExtraAsCost()
end
function cm.thfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToHand()
end
cm.cost=RD.CostSendMatchToDeckSort(cm.costfilter,LOCATION_ONFIELD,1,1,true,SEQ_DECKTOP,true,true)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,2,nil,function(g)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,1),m,tp,list[2])
end