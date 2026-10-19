local cm,m=GetID()
cm.name="U·更新维护"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck,nil,nil,cm.limit)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsOnField() and c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
		and c:IsAttackBelow(2000)
end
function cm.exfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.limit(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateHintEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return c:IsLevelAbove(7)
end