local cm,m=GetID()
local list={120260009}
cm.name="宇宙呼唤"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsRace(RACE_CYBERSE) and not c:IsPublic()
end
function cm.spfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_GRAVE)
		and Duel.GetMZoneCount(tp)>0 and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg,og=RD.SendDeckTopToGraveAndCanSelect(tp,3,aux.Stringid(m,1),HINTMSG_SPSUMMON,aux.NecroValleyFilter(cm.spfilter),1,1,e,tp)
	local tc=sg:GetFirst()
	if tc then
		Duel.BreakEffect()
		local ex=tc:IsCode(list[1])
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		if ex then
			RD.CanDraw(aux.Stringid(m,2),tp,1)
		end
	end
end