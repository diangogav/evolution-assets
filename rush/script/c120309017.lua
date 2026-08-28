local cm,m=GetID()
local list={120130000,120309006}
cm.name="骑士的称号"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsRace(RACE_SPELLCASTER)
		and c:IsAbleToGraveAsCost()
end
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.spfilter(c,e,tp)
	return c:IsCode(list[2]) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,function(g)
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0
			and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
			RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP,true)
		end
	end)
end