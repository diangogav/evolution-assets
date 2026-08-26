local cm,m=GetID()
local list={120105001,120228050}
cm.name="大道武器-七魔导枪"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	RD.RegisterEquipEffect(c,cm.condition,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
	--Indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(cm.indval)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsCode(list[2])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsCode(list[1])
end
--Atk Up
function cm.upfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.upval(e,c)
	local g=Duel.GetMatchingGroup(cm.upfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetAttribute)*400
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP,true)