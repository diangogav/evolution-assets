local cm,m=GetID()
cm.name="诡术师"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandToGraveSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter,1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsAbleToGraveAsCost()
end