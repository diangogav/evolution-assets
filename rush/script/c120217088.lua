local cm,m=GetID()
cm.name="东方虎"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.exfilter(c)
	return c:IsType(TYPE_SPELL)
end
cm.cost=RD.CostChangeSelfPosition()
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=Duel.GetMatchingGroupCount(cm.filter,tp,0,LOCATION_GRAVE,nil)*100
	if chk==0 then return dam>0 end
	RD.TargetDamage(1-tp,dam)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetMatchingGroupCount(cm.filter,tp,0,LOCATION_GRAVE,nil)*100
	if RD.Damage(nil,dam)~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,0,LOCATION_GRAVE,10,nil) then
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end