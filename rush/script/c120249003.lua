local cm,m=GetID()
cm.name="大接合科技要塞霸王龙［L］"
function cm.initial_effect(c)
	--Multiple Attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
	--MaximumMode
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(m,4))
	e2:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_XMATERIAL)
	e2:SetLabel(m)
	e2:SetTarget(cm.target)
	c:RegisterEffect(e2)
end
cm.toss_coin=true
--Multiple Attack
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if RD.IsMaximumMode(e:GetHandler()) then
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,-600,0,reset)
		local res=Duel.TossCoin(tp,1)
		if res==1 then
			RD.AttachExtraAttack(e,c,2,aux.Stringid(m,1),reset)
		else
			RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,2),reset)
			RD.AttachPierce(e,c,aux.Stringid(m,3),reset)
		end
	end
end