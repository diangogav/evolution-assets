local cm,m=GetID()
local list={120304064}
cm.name="讹魔欺乘之不老实蒂斯"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Special Summon Procedure
	RD.AddFieldToGraveSpecialSummonProcedure(c,aux.Stringid(m,0),cm.spconfilter,LOCATION_MZONE,1)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Special Summon Procedure
function cm.spconfilter(c)
	return c:IsAbleToGraveAsCost()
end
--Atk Up
function cm.thfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler())
end
cm.cost=RD.CostSendDeckTopToGrave(3)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,2000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			Duel.BreakEffect()
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end