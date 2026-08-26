local cm,m=GetID()
local list={120293058,120293060,CARD_CODE_OTS}
cm.name="破界王帝 外宇宙界愿"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Maximum Summon
	RD.AddMaximumProcedure(c,3800,list[1],list[2])
	--Change Code
	RD.EnableChangeCode(c,list[3],LOCATION_GRAVE)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(RD.MaximumMode)
	e1:SetTarget(cm.atktg)
	e1:SetValue(-3000)
	c:RegisterEffect(e1)
	--Change Race
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.excon)
	e2:SetValue(RACE_GALAXY)
	c:RegisterEffect(e2)
	--Pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(cm.excon)
	c:RegisterEffect(e3)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1,e2,e3)
end
--Atk Down
function cm.atktg(e,c)
	return c:IsFaceup() and not c:IsRace(RACE_GALAXY)
end
--Change Race
function cm.excon(e)
	return RD.MaximumMode(e) and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end