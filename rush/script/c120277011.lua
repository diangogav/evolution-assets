local cm,m=GetID()
cm.name="宇宙树顶苍鹰"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Cannot Change Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.postg)
	e2:SetValue(cm.posval)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(cm.filter,c:GetControler(),LOCATION_MZONE,0,nil)*800
end
--Cannot Change Position
function cm.postg(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_CYBERSE)
end
function cm.posval(e,re,r,rp)
	return re and r&REASON_EFFECT~=0 and rp~=e:GetHandlerPlayer()
end