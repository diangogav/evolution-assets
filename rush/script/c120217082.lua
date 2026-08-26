local cm,m=GetID()
cm.name="僵尸烟花"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE) and not c:IsPublic()
end
function cm.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_ZOMBIE) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.tgfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,2,nil,e,POS_FACEUP)~=0 then
		RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.tgfilter,tp,LOCATION_HAND,0,1,1,nil,function(g)
			Duel.BreakEffect()
			Duel.SendtoGrave(g,REASON_EFFECT)
		end)
	end
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,1),RACE_ALL-RACE_ZOMBIE,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end