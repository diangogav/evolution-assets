local cm,m=GetID()
cm.name="超可爱执行者·细剑女"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spcon)
	--Atk & Def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(cm.downtg)
	e1:SetValue(-300)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsFaceup() and c:IsLevel(6) and RD.IsDefense(c,500)
end
function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
--Atk & Def
function cm.downtg(e,c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end