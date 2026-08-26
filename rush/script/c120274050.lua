local cm,m=GetID()
cm.name="恐龙体温"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(cm.indval)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(cm.prctg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Cannot To Hand & Deck & Extra
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e4:SetCondition(cm.condition)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e5)
end
--Activate
function cm.target(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_DINOSAUR)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,true)
--Pierce
function cm.prctg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end
--Cannot To Hand & Deck & Extra
function cm.condition(e)
	local tc=e:GetHandler():GetEquipTarget()
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()~=tp and tc:IsControler(tp)
end