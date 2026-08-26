local cm,m=GetID()
local list={120247005,120207007}
cm.name="鹰身女郎2·3"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Cannot Activate
	local e1,e2,e3=RD.ContinuousSummonNotChainTrap(c,20279003,cm.filter)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3,RD.EnableChangeCode(c,list[2],LOCATION_MZONE))
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST)
end
--Cannot Activate
function cm.filter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsFaceup() and c:IsSummonPlayer(tp)
end