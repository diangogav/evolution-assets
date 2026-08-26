local cm,m=GetID()
cm.name="柳安妹妹·心叶"
function cm.initial_effect(c)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.downtg)
	e1:SetValue(cm.downval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Atk Down
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
function cm.condition(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function cm.downtg(e,c)
	return c:IsFaceup()
end
function cm.downval(e)
	return Duel.GetMatchingGroupCount(cm.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-500
end