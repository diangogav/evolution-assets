local cm,m=GetID()
cm.name="电子鲨"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureZero(c,aux.Stringid(m,0),cm.sumcon)
end
--Summon Procedure
function cm.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
function cm.sumcon(c,e,tp)
	return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil)
end