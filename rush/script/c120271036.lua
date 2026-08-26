local cm,m=GetID()
local list={120196050}
cm.name="钢铁徽章融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return c:IsRace(RACE_CYBORG)
end
function cm.thfilter(c,mat)
	return (c:IsCode(list[1]) or (mat:IsContains(c) and c:IsLocation(LOCATION_GRAVE))) and c:IsAbleToHand()
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	local filter=RD.Filter(cm.thfilter,mat)
	RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		Duel.BreakEffect()
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
end