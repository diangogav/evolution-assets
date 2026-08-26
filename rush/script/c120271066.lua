local cm,m=GetID()
local list={120271066}
cm.name="秩序守护者"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spcon)
end
--Special Summon Procedure
function cm.spfilter(c)
	return not c:IsCode(list[1]) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(cm.spfilter,tp,LOCATION_MZONE,0,nil)==2
end