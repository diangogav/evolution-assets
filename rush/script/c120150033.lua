local cm,m=GetID()
cm.name="鼓点雷甲赠礼"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_THUNDER)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_MZONE,0,nil)*500
	if chk==0 then return dam>0 end
	RD.TargetDamage(1-tp,dam)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.Damage(nil,Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_MZONE,0,nil)*500)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotAttackEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end