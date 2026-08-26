local cm,m=GetID()
local list={120105001}
cm.name="七魔导奇妙融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,cm.exfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsOnField() and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,list[1])
end