local cm,m=GetID()
local list={120145000,120125001}
cm.name="变形史莱姆-恶魔龙形态"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,nil,nil,nil,nil,nil,nil,false,true)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.spfilter(c)
	return aux.IsMaterialListCode(c,list[1]) or aux.IsMaterialListCode(c,list[2])
end
cm.cost=RD.CostSendSelfToGrave()