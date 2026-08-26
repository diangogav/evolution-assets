local cm,m=GetID()
cm.name="伊苏椅的镜王 达宇·深渊"
function cm.initial_effect(c)
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
	return c:IsAttack(0) and c:IsAbleToDeckOrExtraAsCost()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,1,99,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()*300
	if atk==0 then return end
	local c=e:GetHandler()
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,function(g)
		RD.AttachAtkDef(e, g:GetFirst(),-atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			RD.AttachAtkDef(e, c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end