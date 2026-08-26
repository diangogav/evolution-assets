local cm,m=GetID()
cm.name="银河冠临夏娃"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.costfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAttackAbove(1600) and c:IsAbleToGraveAsCost()
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=1
	if not Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,2,nil) then
		ct=2
	end
	if chk==0 then return e:GetHandler():IsAbleToGrave() and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsControler(tp)
		and Duel.SendtoGrave(c,REASON_EFFECT)~=0
		and Duel.Draw(tp,1,REASON_EFFECT)~=0
		and not Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,4,nil) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end