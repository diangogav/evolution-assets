local cm,m=GetID()
local list={120238036}
cm.name="名匠之兜"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cm.upval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(200)
	c:RegisterEffect(e2)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup()
end
--Atk & Def Up
function cm.upval(e,c)
	local atk=200
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsCode(list[1]) or (RD.IsLegendCard(ec) and ec:GetOriginalLevel()<=4) then
		atk=atk+ec:GetBaseAttack()
	end
	return atk
end