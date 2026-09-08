local cm,m=GetID()
cm.name="云海龙 尼莫拉"
function cm.initial_effect(c)
	--Union
	local e1=RD.RegisterUnionEffect(c,cm.filter,nil,cm.cost,cm.operation)
	e1:SetCategory(e1:GetCategory()|CATEGORY_TODECK)
	--Def Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetCondition(aux.IsUnionState)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
--Union
function cm.costfilter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_COST)
end
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
end
function cm.exfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
cm.cost=RD.CostChangePosition(cm.costfilter,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,cm.exfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
		Duel.BreakEffect()
		RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)
	end)
end