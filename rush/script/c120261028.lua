local cm,m=GetID()
cm.name="岩石魔神 瓦砾王"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.confilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_ROCK)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevel(5,6,7)
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(7)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_MZONE,0,nil)==2
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,1400,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local g1=Duel.GetMatchingGroup(cm.exfilter,tp,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
		if g1:GetClassCount(Card.GetLevel)==3 and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			Duel.Destroy(g2,REASON_EFFECT)
		end
	end
end