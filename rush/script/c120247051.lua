local cm,m=GetID()
cm.name="幻坏剑 建筑五指剑"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_WYRM)
end
--Atk Up
function cm.upfilter(c)
	return c:IsRace(RACE_WYRM)
end
function cm.upval(e,c)
	if Duel.IsExistingMatchingCard(cm.upfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,5,nil) then
		return 1000
	else
		return 500
	end
end