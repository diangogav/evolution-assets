local cm,m=GetID()
cm.name="牵引的牧牛医"
function cm.initial_effect(c)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Recover
function cm.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
cm.cost=RD.CostSendMZoneToGrave(Card.IsAbleToGraveAsCost,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetRecover(tp,300)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Recover()~=0 then
		RD.CanFusionSummon(aux.Stringid(m,1),cm.matfilter,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,e,tp,POS_FACEUP,true)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateHintEffect(e,aux.Stringid(m,2),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end