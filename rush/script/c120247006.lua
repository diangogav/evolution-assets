local cm,m=GetID()
local list={120207007}
cm.name="鹰身女郎3"
function cm.initial_effect(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:GetFlagEffect(FLAG_CANNOT_ATTACK_UNTIL_NEXT_TURN)==0
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN
		RD.ChangeCode(e,c,list[1],reset)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			Duel.BreakEffect()
			local tc=g:GetFirst()
			RD.AttachCannotAttack(e,tc,aux.Stringid(m,3),reset)
			if not tc:IsImmuneToEffect(e) then
				tc:RegisterFlagEffect(FLAG_CANNOT_ATTACK_UNTIL_NEXT_TURN,reset,0,1)
			end
		end)
	end
end