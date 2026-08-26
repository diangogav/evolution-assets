local cm,m=GetID()
cm.name="暗冥矮星"
function cm.initial_effect(c)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,nil,nil,nil,nil,nil,nil,true)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField()
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function cm.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and c:IsAbleToGraveAsCost()
		and RD.IsCanFusionSummon(e,tp,POS_FACEUP,cm.matfilter,cm.spfilter,nil,0,0,nil,true,false,c)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1,true)