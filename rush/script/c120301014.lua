local cm,m=GetID()
local list={120301002}
cm.name="水灵术师的使魔"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Attribute Change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Attribute Change
function cm.filter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_WATER)
end
function cm.exfilter(c,e,tp)
	return c:IsFacedown() and c:IsCode(list[1]) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
cm.cost1=RD.CostSendSelfToGrave()
cm.cost2=RD.CostSendDeckTopToGrave(1)
cm.cost=RD.CostChoose(aux.Stringid(m,1),cm.cost1,aux.Stringid(m,2),cm.cost2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,3),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.ChangeAttribute(e,g:GetFirst(),ATTRIBUTE_WATER,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local filter=RD.Filter(cm.exfilter,e,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,4),HINTMSG_POSITION,filter,tp,LOCATION_MZONE,0,1,1,nil,function(sg)
			Duel.BreakEffect()
			RD.ChangePosition(sg,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
		end)
	end)
end