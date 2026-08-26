local cm,m=GetID()
local list={120208006}
cm.name="咩～界的王姬 咩～歌小妹"
function cm.initial_effect(c)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter,cm.matfilter)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsFusionType(TYPE_NORMAL) and c:IsRace(RACE_BEAST)
end