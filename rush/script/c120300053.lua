local cm,m=GetID()
local list={120300053}
cm.name="火面味变化之术"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAttack(2900)
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,c)
end
function cm.filter(c,fc)
	return c:IsFaceup() and RD.IsCanAnnounceFusionMaterialCode(c,fc)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
cm.cost=RD.CostShowExtra(cm.costfilter,1,1,nil,Group.GetFirst)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	local mg=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil,tc)
	local ec=e:GetHandler()
	if mg:GetClassCount(Card.GetCode)==1 then
		ec=mg:GetFirst()
	end
	local ac=RD.AnnounceFusionMaterialCode(tp,ec,tc)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local filter=RD.Filter(cm.filter,tc)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.ChangeCode(e,g:GetFirst(),ac,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end