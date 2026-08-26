local cm,m=GetID()
cm.name="诅咒的慕名信"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_ZOMBIE)
		and RD.IsCanChangePosition(c,e,tp,REASON_COST)
end
function cm.filter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsRace(RACE_ZOMBIE)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.costfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	RD.ChangePosition(g,e,tp,REASON_COST,POS_FACEUP_DEFENSE)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_MZONE,0,nil)
	local dam=RD.SendOpponentHandToGrave(tp,aux.Stringid(m,1),1,ct)*300
	if dam>0 then
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end