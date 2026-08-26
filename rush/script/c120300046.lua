local cm,m=GetID()
local list={120300047,120300048,120300061,120300008,120300037}
cm.name="冥迹祭-伊西利亚的降灵-"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsCode(list[4])
end
function cm.spfilter(c)
	return c:IsCode(list[5])
end
function cm.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFacedown()) and c:IsCode(list[1],list[2],list[3])
		and c:IsAbleToGraveAsCost()
end
function cm.check(g)
	return g:GetClassCount(Card.GetCode)==g:GetCount()
end
cm.cost=RD.CostSendHandOrFieldSubToGrave(cm.costfilter,cm.check,3,3,true)