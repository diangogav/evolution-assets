local cm,m=GetID()
local list={120264031}
cm.name="叛骨装典 苏芙蕾楼罗"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	RD.AddRitualProcedure(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.damcon)
	e1:SetOperation(cm.damop)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2)
end
--Damage
function cm.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER)
		and rc:IsControler(tp) and rc:GetOriginalRace()&RACE_ZOMBIE==RACE_ZOMBIE
		and Duel.GetTurnPlayer()==tp
end
function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,LOCATION_GRAVE,0,nil,1)
	if sg:GetCount()>0 then
		local _,lv=sg:GetMaxGroup(Card.GetLevel)
		Duel.Hint(HINT_CARD,0,m)
		Duel.Damage(1-tp,lv*200,REASON_EFFECT)
	end
end
--Indes
function cm.indcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,list[1])
		and e:GetHandler():IsDefensePos()
end