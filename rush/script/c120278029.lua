local cm,m=GetID()
local list={120231024}
cm.name="电子超速融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,5)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return aux.IsMaterialListCode(c,list[1])
end
function cm.exfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()<=5
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	g:RemoveCard(fc)
	Duel.Destroy(g,REASON_EFFECT)
end