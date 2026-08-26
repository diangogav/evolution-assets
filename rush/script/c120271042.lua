local cm,m=GetID()
local list={120238005}
cm.name="大传说的魔术师"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fake Legend
	RD.EnableFakeLegend(c,LOCATION_HAND+LOCATION_GRAVE)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.costfilter(c)
	return (c:IsCode(list[1]) or RD.IsLegendCard(c)) and not c:IsPublic()
end
function cm.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end