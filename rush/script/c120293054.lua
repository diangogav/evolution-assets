local cm,m=GetID()
local list={120261058}
cm.name="搅拌的宇宙姬"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,3)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsRace(RACE_GALAXY) and (RD.IsDefense(c,1900) or RD.IsDefense(c,2600))
end
function cm.exfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()<=3
end
function cm.confilter(c)
	return c:IsRace(RACE_GALAXY)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,5,nil)
end
cm.cost=RD.CostSendHandToDeckBottom(Card.IsAbleToDeckAsCost,1,1,false)