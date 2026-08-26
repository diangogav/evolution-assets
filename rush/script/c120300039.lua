local cm,m=GetID()
cm.name="太阴月力年糕猫"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
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
	if c:IsOnField() and not c:IsFaceup() then return false end
	if c:IsLocation(LOCATION_GRAVE) and not c:IsType(TYPE_MONSTER) then return false end
	return c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
cm.cost=RD.CostSendMatchToDeckSort(cm.costfilter,LOCATION_MZONE+LOCATION_GRAVE,3,3,true,SEQ_DECKBOTTOM,false,true)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0
			and Duel.IsExistingMatchingCard(cm.exfilter,tp,0,LOCATION_GRAVE,5,nil) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end)
		end
	end)
end