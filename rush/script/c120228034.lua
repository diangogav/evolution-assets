local cm,m=GetID()
cm.name="天启之监视者"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.condition)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Indes
function cm.filter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.condition(e)
	return Duel.IsExistingMatchingCard(cm.filter,e:GetHandlerPlayer(),0,LOCATION_GRAVE,6,nil)
end
function cm.indval(e,re,rp)
	if e==nil then
		return true,TYPE_MONSTER,0
	end
	local tp=e:GetHandlerPlayer()
	local tc=re:GetHandler()
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and tc:IsLevelBelow(8)
end