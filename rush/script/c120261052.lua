local cm,m=GetID()
cm.name="混合驱动回归融合"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c,e,tp)
	return RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEDOWN_DEFENSE)
end
function cm.exfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetRace)==sg:GetCount()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,4,4)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(1-tp)>0
		and Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_GRAVE,1,nil,e,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(cm.filter,1-tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEDOWN_DEFENSE)~=0 then
		RD.SetFusionSummonMaterialCount(e,2,2)
		RD.CanFusionSummon(aux.Stringid(m,1),aux.FALSE,nil,cm.exfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck,e,tp,POS_FACEUP,true)
		RD.ResetFusionSummonMaterialCount(e)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateHintEffect(e,aux.Stringid(m,2),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not c:IsType(TYPE_FUSION)
end