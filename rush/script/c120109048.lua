local cm,m=GetID()
local list={120222025,120227007}
cm.name="虚空噬骸兵·狱魔导鹰巨人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.exfilter(c)
	return RD.IsNormalSpell(c)
end
function cm.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler(),SUMMON_TYPE_FUSION)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,2,2,nil,nil,function(g)
	return g:FilterCount(cm.exfilter,nil)
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_RTOHAND,cm.filter,tp,0,LOCATION_ONFIELD,1,2,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) and e:GetLabel()==2 and Duel.GetFlagEffect(tp,m)==0 then
			RD.CreateCannotActivateEffect(e,aux.Stringid(m,1),cm.aclimit,tp,1,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
		end
	end)
end
function cm.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return re:IsActiveType(TYPE_SPELL) and RD.IsNormalSpell(tc)
end