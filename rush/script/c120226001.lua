local cm,m=GetID()
cm.name="分析燃素灵"
function cm.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function cm.filter(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_PYRO) and c:IsAbleToDeck()
end
function cm.desfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevelBelow(8)
end
function cm.check(g,lv)
	return g:GetSum(Card.GetLevel,nil)==lv
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
	local lv=g:GetSum(Card.GetLevel,nil)
	local sg=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return sg:CheckSubGroup(cm.check,3,3,lv) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
	local lv=g:GetSum(Card.GetLevel,nil)
	local check=RD.Check(cm.check,lv)
	RD.SelectGroupAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),check,tp,LOCATION_GRAVE,0,3,3,nil,function(sg)
		if RD.SendToDeckAndExists(sg,e,tp,REASON_EFFECT) then
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateHintEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateOnlySoleAttackEffect(e,20226001,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end