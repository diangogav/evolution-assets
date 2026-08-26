local cm,m=GetID()
cm.name="梦中的再诞"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,0,LOCATION_MZONE,cm.matcheck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,2)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(cm.condition2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Condition
	e1:SetCondition(cm.condition1)
end
--Activate
function cm.confilter(c)
	return c:IsRace(RACE_INSECT)
end
function cm.matfilter(c)
	return c:IsOnField() and c:IsFaceup()
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_INSECT)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(9)
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()==2 and sg:IsExists(Card.IsControler,1,nil,tp)
		and sg:IsExists(Card.IsLevelBelow,1,nil,9)
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and ep~=tp
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
end