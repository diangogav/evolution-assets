local cm,m=GetID()
cm.name="疾风之暗黑骑士 盖亚"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureZero(c,aux.Stringid(m,0),cm.sumcon)
end
--Summon Procedure
function cm.sumcon(c,e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
end