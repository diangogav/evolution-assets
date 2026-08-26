local cm,m=GetID()
cm.name="无貌之死路魔"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandConfirmSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cm.uptg)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Special Summon Procedure
function cm.spconfilter(c,tp,e,tc)
	return c~=tc and c:IsRace(RACE_FIEND) and not c:IsPublic()
end
--Atk Up
function cm.uptg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end