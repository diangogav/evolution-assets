local cm,m=GetID()
cm.name="哨兵军官"
function cm.initial_effect(c)
	--Discard Deck
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,cm.matcheck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(2,2)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
--Discard Deck
function cm.confilter1(c)
	return c:IsRace(RACE_GALAXY)
end
function cm.confilter2(c)
	return c:IsType(TYPE_MONSTER) and not cm.confilter1(c)
end
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
function cm.spfilter(c)
	return c:IsLevel(9) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY)
end
function cm.matcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetAttribute)==sg:GetCount()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(cm.confilter2,tp,LOCATION_GRAVE,0,1,nil)
end