local cm,m=GetID()
cm.name="变形史莱姆-龙骑士形态"
function cm.initial_effect(c)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,nil,0,0,cm.matcheck)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(2,2)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.costfilter(c)
	return not c:IsType(TYPE_FUSION) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.matfilter(c)
	return (c:IsLevel(7) and c:IsRace(RACE_WARRIOR)) or (c:IsLevel(5) and c:IsRace(RACE_DRAGON))
end
function cm.matcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetLevel)==sg:GetCount()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,1,1)