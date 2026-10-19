local cm,m=GetID()
cm.name="进行腐灼的恶果"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Special Summon Condition
	RD.OnlySpecialSummonByEffect(c,cm.splimit)
	--Atk & Def Down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(cm.downtg)
	e1:SetValue(-2000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Special Summon Condition
function cm.splimit(e,se,sp,st)
	return se:IsActiveType(TYPE_SPELL)
end
--Atk & Def Down
function cm.downtg(e,c)
	return c:IsFaceup() and not RD.IsBaseDefense(c,1000)
end