local cm,m=GetID()
local list={120293001}
cm.name="超战士的闪光"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.costfilter1(c)
	return c:IsAbleToDeckAsCost()
end
function cm.costfilter2(c,e,tp)
	return c:IsFaceup() and c:IsCode(list[1]) and RD.IsCanChangePosition(c,e,tp,REASON_COST)
end
function cm.filter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and c:IsCanTurnSet()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsCode(list[1])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost1=RD.CostSendHandToDeckBottom(cm.costfilter1,1,1,false)
cm.cost2=RD.CostChangePosition(cm.costfilter2,1,1)
cm.cost=RD.CostChoose(HINTMSG_TODECK,cm.cost1,HINTMSG_POSCHANGE,cm.cost2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	local max=1
	if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		max=2
	end
	RD.SelectAndDoAction(HINTMSG_SET,filter,tp,0,LOCATION_MZONE,1,max,nil,function(g)
		RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)
	end)
end