local cm,m=GetID()
cm.name="化学宠物·喵喵"
function cm.initial_effect(c)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Recover
function cm.confilter(c)
	return c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER)
end
function cm.exfilter(c)
	return c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER) and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetRecover(tp,400)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Recover()~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.exfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			if RD.SendToDeckTop(g,e,tp,REASON_EFFECT)~=0 then
				Duel.ConfirmDecktop(tp,1)
			end
		end)
	end
end