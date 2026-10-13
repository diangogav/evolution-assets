local cm,m=GetID()
local list={120311030,120263008}
cm.name="元素英雄 荒野翼侠"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Only Fusion Summon
	RD.OnlyFusionSummon(c)
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
function cm.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.max(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cm.filter,tp,0,LOCATION_ONFIELD,nil)
	return math.min(ct,4)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,cm.max,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter,tp,0,LOCATION_ONFIELD,ct,ct,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end