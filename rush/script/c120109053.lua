local cm,m=GetID()
local list={120213023}
cm.name="不球而遇扭蛋机会"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function cm.spfilter(c,e,tp)
	return (c:IsCode(list[1])
		or (c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)))
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.spcheck(g)
	local ct=g:GetCount()
	return ct==1 or g:FilterCount(Card.IsCode,nil,list[1])==ct
end
cm.cost=RD.CostSendHandOrFieldToGrave(cm.costfilter,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	RD.TargetDiscardDeck(tp,3)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.DiscardDeck()~=0 and Duel.GetOperatedGroup():IsExists(cm.exfilter,1,nil) then
		RD.CanSelectGroupAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),cm.spcheck,tp,LOCATION_GRAVE,0,1,3,nil,e,POS_FACEUP,true)
	end
end