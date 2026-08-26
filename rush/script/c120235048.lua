local cm,m=GetID()
cm.name="倍斩刃"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
	--Cannot Direct Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
end
--Activate
function cm.filter(c,tc)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and RD.IsSameCode(c,tc)
end
function cm.target(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON)
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,c,c)
end
--Atk Up
function cm.upval(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:GetBaseAttack() 
end