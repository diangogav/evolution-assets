local cm,m=GetID()
cm.name="兽剑 虎齿剑"
function cm.initial_effect(c)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(900)
	c:RegisterEffect(e1)
	--Double Tribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(cm.trival)
	c:RegisterEffect(e2)
end
--Activate
cm.trival=RD.ValueDoubleTributeAll(true)
function cm.target(c,e,tp,chk)
	return c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAttackBelow(1400)
end