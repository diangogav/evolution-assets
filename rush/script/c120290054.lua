local cm,m=GetID()
local list={120130000,120170000}
cm.name="奇迹之秘术"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,cm.exfilter,LOCATION_GRAVE,0,cm.check,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,2)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return RD.IsLegendCode(c,list[1],list[2])
end
function cm.matfilter(c)
	return cm.filter(c) and c:IsOnField() and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return cm.filter(c) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.check(tp,sg,fc)
	return sg:IsExists(Card.IsOnField,1,nil) and sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end