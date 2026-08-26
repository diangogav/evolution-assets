local cm,m=GetID()
local list={120293068,120293065}
cm.name="英魂的凭依"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fake Legend
	RD.EnableFakeLegend(c,LOCATION_HAND+LOCATION_GRAVE)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,nil,cm.spfilter)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
function cm.ritual_mat_filter(c)
	return not c:IsLocation(LOCATION_HAND) or RD.IsLegendCard(c)
end
--Activate
function cm.spfilter(c)
	return c:IsCode(list[2])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end