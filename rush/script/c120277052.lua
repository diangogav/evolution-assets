local cm,m=GetID()
cm.name="虚空尘融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,aux.FALSE,cm.spfilter,cm.matfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,2)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsType(TYPE_NORMAL)
		and c:IsAbleToDeckOrExtraAsCost()
		and RD.IsCanFusionSummon(e,tp,POS_FACEUP,aux.FALSE,cm.spfilter,cm.matfilter,LOCATION_GRAVE,0,cm.matcheck,false,false,c)
end
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsLevel(9) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
		and RD.IsDefenseAbove(c,2000)
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()==2
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	RD.CreateHintEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateOnlyThatAttackEffect(e,fc,20277052,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
end