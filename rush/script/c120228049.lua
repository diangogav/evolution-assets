local cm,m=GetID()
cm.name="花牙分身"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT) and c:IsLevelAbove(1)
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
function cm.spfilter(c,e,tp,lv)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT) and c:IsLevelBelow(lv)
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevel(5)
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7)
end
cm.cost=RD.CostSendHandToDeckBottom(Card.IsAbleToDeckAsCost,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<1 then return end
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local lv=g:GetFirst():GetLevel()
		local spfilter=function(c,e,tp)
			return cm.spfilter(c,e,tp,lv)
		end
		if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(spfilter),tp,LOCATION_GRAVE,0,1,2,nil,e,POS_FACEUP)~=0
			and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(cm.desfilter,tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
			local dg=Duel.GetMatchingGroup(cm.desfilter,tp,0,LOCATION_MZONE,nil)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end)
end