local cm,m=GetID()
local list={120301020}
cm.name="灵体化的锻炼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function cm.filter(c,attr)
	return c:IsAttribute(attr) and (cm.filter1(c) or cm.filter2(c)) and c:IsAbleToHand()
end
function cm.filter1(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttack(c,500,1900) and RD.IsDefense(c,1500)
end
function cm.filter2(c)
	return c:IsLevel(4) and c:IsAttack(c,1500) and RD.IsDefense(c,200)
end
function cm.costcheck(g,e,tp)
	return g:GetClassCount(Card.GetAttribute)==1
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil,g:GetFirst():GetAttribute())
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (cm.filter1(tc1) and cm.filter2(tc2))
		or (cm.filter1(tc2) and cm.filter2(tc1))
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
cm.cost=RD.CostShowGroupHand(cm.costfilter,cm.costcheck,2,2,function(g)
	return g:GetFirst():GetAttribute()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e:GetLabel())
	RD.SelectGroupAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(filter),cm.check,tp,LOCATION_GRAVE,0,1,2,nil,function(g)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
end