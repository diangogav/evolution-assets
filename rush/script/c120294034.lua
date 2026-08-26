local cm,m=GetID()
cm.name="邪心之魔龙小丑"
function cm.initial_effect(c)
	--Control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Control
function cm.costfilter(c,e,tp)
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
function cm.filter(c,ignore)
	return c:IsFaceup() and not c:IsType(TYPE_MAXIMUM) and c:IsLevelBelow(8)
		and c:IsControlerCanBeChanged(ignore)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerDrawInThisTurn(1-tp)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e:IsCostChecked()) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,false)
	RD.SelectAndDoAction(HINTMSG_CONTROL,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.GetControl(g,tp)
	end)
end