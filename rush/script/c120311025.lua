local cm,m=GetID()
local list={120311025,120311026}
cm.name="暗黑神召"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeckBottom)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetValue(SUMMON_VALUE_DARK_FUSION)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
function cm.matfilter(c)
	return not c:IsOnField() and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return aux.IsCodeListed(c,list[2])
end