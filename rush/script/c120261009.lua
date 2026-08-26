local cm,m=GetID()
cm.name="化学宠物·鹦鹦"
function cm.initial_effect(c)
	--Discard Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.costfilter(c)
	return c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER) and not c:IsPublic()
end
function cm.thfilter(c,lv)
	return c:IsRace(RACE_PYRO+RACE_AQUA+RACE_THUNDER) and c:IsLevel(lv)
		and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1,function(g)
	return g:GetFirst():GetLevel()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local filter=aux.NecroValleyFilter(RD.Filter(cm.thfilter,lv))
	local sg,og=RD.SendDeckTopToGraveAndCanSelect(tp,3,aux.Stringid(m,1),HINTMSG_ATOHAND,filter,1,1)
	if sg:GetCount()>0 then
		Duel.BreakEffect()
		RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
	end
end