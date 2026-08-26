local cm,m=GetID()
cm.name="花牙缝"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT)
end
function cm.atkfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT)
end
function cm.exfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(5)
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7)
end
cm.cost=RD.CostSendDeckTopToGrave(3)
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(cm.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetMatchingGroupCount(cm.atkfilter,tp,LOCATION_GRAVE,0,nil)*-100
	if atk==0 then return end
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(cm.desfilter,tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
			local dg=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end)
end