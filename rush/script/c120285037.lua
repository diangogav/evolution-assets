local cm,m=GetID()
local list={120222017,120225001}
cm.name="紫鳞弹超越爆击速龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],list[2])
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
function cm.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
function cm.atkcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function cm.atkval(e,c)
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(cm.atkfilter,tp,0,LOCATION_MZONE,nil)
	if mg:GetCount()>0 then
		local _,atk=mg:GetMaxGroup(Card.GetBaseAttack)
		return atk
	else
		return 0
	end
end