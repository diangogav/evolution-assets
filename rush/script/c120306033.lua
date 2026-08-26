local cm,m=GetID()
cm.name="圣寂之护卫者 雅耳典娜"
function cm.initial_effect(c)
	--Special Summon Procedure
	RD.AddHandConfirmSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter)
	--Union
	RD.RegisterUnionEffect(c,aux.TRUE,nil,cm.cost)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--Cannot Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(cm.actcon)
	e2:SetOperation(cm.actlimit)
	c:RegisterEffect(e2)
end
--Special Summon Procedure
function cm.spconfilter(c,tp,e,tc)
	return c~=tc and c:IsType(TYPE_UNION) and not c:IsPublic()
end
--Union
cm.cost=RD.CostSendDeckTopToGrave(2)
--Cannot Activate
function cm.actcon(e)
	return aux.IsUnionState(e) and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.actlimit(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	if c:IsFaceup() and e:GetHandler():GetEquipTarget()==c then
		Duel.Hint(HINT_CARD,0,m)
		Duel.SetChainLimitTillChainEnd(cm.chainlimit)
	end
end
function cm.chainlimit(e,rp,tp)
	return not (rp~=tp and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:IsActiveType(TYPE_TRAP))
end