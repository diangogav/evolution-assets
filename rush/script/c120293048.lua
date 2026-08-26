local cm,m=GetID()
local list={120293046,120261058}
cm.name="惑精的洋干菊土星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Procedure
	RD.AddHandConfirmSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsCode(list[1],list[2]) and not c:IsPublic()
end
--Fusion Summon
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_GALAXY)
end
function cm.spfilter(c)
	return c:IsRace(RACE_GALAXY) and (RD.IsDefense(c,1900) or RD.IsDefense(c,2600))
end