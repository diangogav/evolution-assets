local cm,m=GetID()
local list={CARD_CODE_OTS}
cm.name="破界王帝 外宇宙界愿［R］"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(cm.atkcon)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Atk Up
function cm.atkfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_GALAXY)
end
function cm.atkcon(e)
	return RD.MaximumMode(e) and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function cm.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(cm.atkfilter,tp,0,LOCATION_MZONE,nil)*3000
end