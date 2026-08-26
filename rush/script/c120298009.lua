local cm,m=GetID()
local list={120264030,120264031}
cm.name="叛骨装魂 梅尼尔"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter1(c)
	return c:IsCode(list[1],list[2])
end
function cm.thfilter2(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL)
end
function cm.thfilter(c)
	return (cm.thfilter1(c) or cm.thfilter2(c)) and c:IsAbleToHand()
end
function cm.check(g)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (cm.thfilter1(tc1) and cm.thfilter2(tc2))
		or (cm.thfilter1(tc2) and cm.thfilter2(tc1))
end
cm.cost=RD.CostSendSelfToGrave()
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(cm.check,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),cm.check,tp,LOCATION_GRAVE,0,2,2,nil,function(g)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
end