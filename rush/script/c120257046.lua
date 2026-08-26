local cm,m=GetID()
local list={120235023,120235021}
cm.name="苍救之晦冥 尼卢克利塔"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.prctg)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Pierce
function cm.prctg(e,c)
	return c:GetEquipCount()>0 and (c:IsRace(RACE_CELESTIALWARRIOR) or c:IsRace(RACE_WARRIOR+RACE_FAIRY))
end