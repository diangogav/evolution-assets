local cm,m=GetID()
local list={120309016,120130000,120181002}
cm.name="蒂迈欧的共斗"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,aux.FALSE,cm.spfilter,cm.matfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,2)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
function cm.spfilter(c)
	return (aux.IsMaterialListCode(c,list[2]) or aux.IsMaterialListCode(c,list[3]))
		and c:IsRace(RACE_DRAGON)
end
function cm.matfilter(c)
	return not c:IsFusionType(TYPE_FUSION) and c:IsFusionAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()==2
end