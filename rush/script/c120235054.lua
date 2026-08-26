local cm,m=GetID()
cm.name="苍救之证"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,cm.condition,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and (c:IsRace(RACE_CELESTIALWARRIOR) or c:IsRace(RACE_WARRIOR+RACE_FAIRY))
end
--Atk Up
function cm.upval(e,c)
	return e:GetHandler():GetEquipTarget():GetLevel()*100
end