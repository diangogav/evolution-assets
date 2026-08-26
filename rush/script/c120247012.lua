local cm,m=GetID()
local list={120207007,120247002}
cm.name="鹰身女妖的正装"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	--Pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(cm.prctg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsCode(list[1],list[2])
end
--Pierce
function cm.prctg(e,c)
	local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return (ct==1 or ct==3) and c==e:GetHandler():GetEquipTarget()
end