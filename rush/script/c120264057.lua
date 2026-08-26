local cm,m=GetID()
cm.name="莓果新人果园"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cm.uptg)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
--Atk
function cm.uptg(e,c)
	return c:IsControler(Duel.GetTurnPlayer()) and c:IsFaceup()
		and RD.IsBaseDefense(c,500) and c:IsRace(RACE_AQUA)
end