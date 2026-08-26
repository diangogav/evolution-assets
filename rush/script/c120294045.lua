local cm,m=GetID()
local list={120160003}
cm.name="死灵女仆·返：D"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.costfilter1(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
end
function cm.costfilter2(c)
	return c:IsRace(RACE_ZOMBIE)
end
function cm.costfilter(c)
	return (cm.costfilter1(c) or cm.costfilter2(c)) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function cm.check(g)
	if g:GetCount()==1 then
		return g:IsExists(cm.costfilter1,1,nil)
	else
		return g:FilterCount(cm.costfilter2,nil)==3
	end
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.check,1,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_RTOHAND,cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
end