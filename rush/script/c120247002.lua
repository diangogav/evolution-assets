local cm,m=GetID()
local list={120247001,120247003}
cm.name="鹰身三姐妹"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Maximum Summon
	RD.AddMaximumProcedure(c,3400,list[1],list[2])
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	if RD.IsMaximumMode(e:GetHandler()) then
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) and RD.IsMaximumMode(c) then
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end)
end