local cm,m=GetID()
cm.name="贯彻到底的千年原人"
function cm.initial_effect(c)
	RD.AddRitualProcedure(c)
	--Double Damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetCondition(cm.damcon)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	--Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.atkcon)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--Continuous Effect
	RD.AddContinuousEffect(c,e2)
end
--Double Damage
function cm.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
--Atk Up
function cm.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,10,nil,TYPE_MONSTER)
end