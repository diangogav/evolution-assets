local cm,m=GetID()
cm.name="β版燃龙"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSummonTurn(e:GetHandler())
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*100
	if chk==0 then return dam>0 end
	RD.TargetDamage(1-tp,dam)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*100
	RD.Damage(nil,dam)
end