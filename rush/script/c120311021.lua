local cm,m=GetID()
cm.name="邪心英雄 恶刃魔"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),cm.sumcon,aux.TRUE)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Summon Procedure
function cm.sumcon(c,e,tp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end