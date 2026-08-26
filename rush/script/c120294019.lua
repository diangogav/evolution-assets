local cm,m=GetID()
local list={120294052,120181001}
cm.name="最强的战旗"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAttack(2500) and RD.IsDefense(c,1600)
end
function cm.thfilter2(c)
	return c:IsCode(list[1])
end
function cm.thfilter(c)
	return (cm.thfilter1(c) or cm.thfilter2(c)) and c:IsAbleToHand()
end
function cm.spfilter(c,e,tp)
	return c:IsCode(list[2]) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (cm.thfilter1(tc1) and cm.thfilter2(tc2))
		or (cm.thfilter1(tc2) and cm.thfilter2(tc1))
end
cm.cost=RD.CostSendSelfToGrave()
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),cm.check,tp,LOCATION_GRAVE,0,1,2,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),cm.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,POS_FACEUP,true)
		end
	end)
end