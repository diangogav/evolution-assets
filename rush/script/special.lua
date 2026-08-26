-- Load Rush Duel
Duel.LoadScript("RDBase.lua")
Duel.LoadScript("RDLegend.lua")
Duel.LoadScript("RDRule.lua")
Duel.LoadScript("RDMaximum.lua")
Duel.LoadScript("RDFunction.lua")
Duel.LoadScript("RDCondition.lua")
Duel.LoadScript("RDCost.lua")
Duel.LoadScript("RDTarget.lua")
Duel.LoadScript("RDValue.lua")
Duel.LoadScript("RDContinuous.lua")
Duel.LoadScript("RDAttach.lua")
Duel.LoadScript("RDLimit.lua")
Duel.LoadScript("RDAction.lua")
Duel.LoadScript("RDFusion.lua")
Duel.LoadScript("RDRitual.lua")
Duel.LoadScript("RDEquip.lua")
Duel.LoadScript("RDSummon.lua")
Duel.LoadScript("RDUnion.lua")
RD = RushDuel

function Auxiliary.PreloadUds()
    RD.Init()
end
