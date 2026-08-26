local cm,m=GetID()
cm.name="僵尸狂欢节"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk & Def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cm.uptg)
	e2:SetValue(cm.upval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
--Atk & Def
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function cm.uptg(e,c)
	return cm.filter(c)
end
function cm.upval(e,c)
	return Duel.GetMatchingGroupCount(cm.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*100
end