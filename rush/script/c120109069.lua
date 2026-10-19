local cm,m=GetID()
local list={120208019,120213010}
cm.name="接合科技王牌霸王龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
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
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			RD.AttachExtraAttack(e,c,1,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end