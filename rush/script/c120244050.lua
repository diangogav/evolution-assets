local cm,m=GetID()
cm.name="虚空噬骸兵金鬃獠牙"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(cm.upcon)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
--Atk Up
function cm.upcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_SPELL,TYPE_SPELL,true)