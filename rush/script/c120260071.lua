local cm,m=GetID()
cm.name="冠狙乐姬 长号弩手"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR) and c:IsAbleToGraveAsCost()
end
function cm.exfilter(c)
	return c:IsType(TYPE_NORMAL)
end
function cm.posfilter(c,e,tp)
	return RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
cm.cost1=RD.CostSendDeckTopToGrave(2)
cm.cost2=RD.CostSendHandToGrave(cm.costfilter,1,1)
cm.cost=RD.CostMerge(cm.cost1,cm.cost2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		local filter=RD.Filter(cm.posfilter,e,tp)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSITION,filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
			RD.ChangePosition(g,e,tp,REASON_EFFECT)
		end)
	end
end