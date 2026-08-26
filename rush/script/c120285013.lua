local cm,m=GetID()
cm.name="花牙女忍·凛花宁祥"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.atkcon)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	--Continuous Effect
	RD.AddContinuousEffect(c,e1)
end
--Atk Up
function cm.confilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
function cm.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==1-tp 
		and not Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cm.atkval(e,c)
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(cm.atkfilter,tp,LOCATION_MZONE,0,nil)
	if mg:GetCount()>0 then
		local _,atk=mg:GetMaxGroup(Card.GetBaseAttack)
		return atk
	else
		return 0
	end
end