local cm,m=GetID()
cm.name="绝望狂魔 死锁岩魔"
function cm.initial_effect(c)
	--Cannot Release
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.sumlimit)
	c:RegisterEffect(e1)
	--Atk Down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.target)
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Cannot Release
function cm.sumlimit(e,c)
	return true
end
--Atk Down
function cm.target(e,c)
	return c:IsFaceup() and not c:IsRace(RACE_FIEND)
end