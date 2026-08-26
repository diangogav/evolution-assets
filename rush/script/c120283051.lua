local cm,m=GetID()
local list={120235003}
cm.name="THE☆对决融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
function cm.fusion_mat_filter(c)
	return c:IsCode(list[1]) or not c:IsRace(RACE_DRAGON)
end
--Activate
function cm.matfilter(c)
	return c:IsOnField() and c:IsFusionType(TYPE_NORMAL) and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return aux.IsMaterialListCode(c,list[1])
end
function cm.exfilter(c)
	return c:IsFusionType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetLocation)==2
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFusionMaterial(tp):IsExists(cm.matfilter,1,nil)
end