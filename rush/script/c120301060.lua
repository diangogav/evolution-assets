local cm,m=GetID()
local list={120301060}
cm.name="疾行狙击手"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.FusionToDeck,nil,nil,cm.limit)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition1)
	c:RegisterEffect(e1)
	local e2=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck,nil,nil,cm.limit)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.condition2)
	c:RegisterEffect(e2)
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not RD.IsSpecialSummonMainPhase(e:GetHandler())
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler())
end
--Fusion Summon
function cm.matfilter(c)
	return c:IsOnField() and c:IsType(TYPE_EFFECT) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsRace(RACE_WARRIOR) and c:IsCanBeFusionMaterial()
		and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsRace(RACE_WARRIOR) and RD.IsDefense(c,2300)
end
function cm.limit(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,1),RACE_ALL-RACE_WARRIOR,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end