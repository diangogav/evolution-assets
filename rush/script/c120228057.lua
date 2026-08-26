local cm,m=GetID()
local list={120183038}
cm.name="扫神降临"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
function cm.costfilter(c,e,tp)
	return not c:IsPublic() and c:IsRace(RACE_FAIRY)
end
function cm.spfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsRace(RACE_FAIRY) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c)
	return not c:IsCode(list[1])
end
function cm.tgfilter(c)
	return c:IsType(TYPE_MONSTER)
end
cm.cost=RD.CostShowHand(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)~=0
		and RD.IsOperatedGroupExists(cm.exfilter,1,nil) then
		RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.tgfilter,tp,LOCATION_HAND,0,2,2,nil,function(g)
			RD.SendToGraveAndExists(g)
		end)
	end
end