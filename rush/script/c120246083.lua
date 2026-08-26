local cm,m=GetID()
cm.name="黑魔术师的宝石"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and (c:IsAttack(2500) or c:IsAttack(2000))
		and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.check(g)
	return g:GetClassCount(Card.GetAttack)==g:GetCount()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and g:CheckSubGroup(cm.check,1,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),cm.check,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,2,nil,e,POS_FACEUP)
end