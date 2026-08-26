local cm,m=GetID()
local list={120272029}
cm.name="龙水之神子"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.desfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
function cm.check(g)
	if g:IsExists(Card.IsCode,1,nil,list[1]) then
		return g:GetCount()==1 or g:GetCount()==4
	else
		return g:GetCount()==4
	end
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.check,1,4)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.desfilter,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_SZONE,1,1,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end