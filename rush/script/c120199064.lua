local cm,m=GetID()
cm.name="螺旋间歇泉"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition1)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(cm.condition2)
	c:RegisterEffect(e3)
end
--Activate
function cm.confilter1(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function cm.confilter2(c,tp)
	return c:IsFacedown() and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter1,1,nil,1-tp)
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter2,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetDamage(1-tp,400)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.Damage()
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateHintEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetLabel(1-tp)
	e1:SetTarget(cm.sumtg)
	e1:SetValue(cm.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.sumtg(e,c)
	return c:IsFacedown()
end
function cm.sumlimit(e,c)
  return c~=nil and c:IsControler(e:GetLabel())
end