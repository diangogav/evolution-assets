local cm,m=GetID()
local list={120120008}
cm.name="大飞蛾"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Procedure
	RD.AddFieldToGraveSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter,LOCATION_MZONE,1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsFaceup() and c:IsCode(list[1]) and c:IsAbleToGraveAsCost()
end