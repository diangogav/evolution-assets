local cm,m=GetID()
local list={120231024}
cm.name="电子强袭龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(list[1])
end
--Destroy
function cm.costfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAttackAbove(2400)
end
cm.cost=RD.CostSendGraveToDeckTop(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end