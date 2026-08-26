local cm,m=GetID()
local list={120263008,120263007,120263006,120263005,120263009,120263004}
cm.name="摩天楼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
		and (c:IsCode(list[1],list[2],list[3],list[4],list[5],list[6])
		or (c:IsType(TYPE_FUSION) and c:IsLevelAbove(5) and c:IsLevelBelow(8) and c:IsRace(RACE_WARRIOR)))
end