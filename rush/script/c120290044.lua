local cm,m=GetID()
local list={120244053,120244010}
cm.name="名流罩衫·死亡单肩衫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Activate
	RD.RegisterEquipEffect(c,nil,nil,cm.target)
	--Fusion Code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_ADD_FUSION_CODE)
	e1:SetValue(list[2])
	c:RegisterEffect(e1)
	--Cannot To Hand & Deck & Extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_TO_HAND_EFFECT)
	e2:SetCondition(cm.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_DECK_EFFECT)
	c:RegisterEffect(e3)
end
--Activate
function cm.target(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup()
end
--Cannot To Hand & Deck & Extra
function cm.condition(e)
	local tc=e:GetHandler():GetEquipTarget()
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()~=tp and tc:IsControler(tp)
end