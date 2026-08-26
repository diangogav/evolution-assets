local cm,m=GetID()
cm.name="兽翼刚王 克麟"
function cm.initial_effect(c)
	--Atk & Def Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk & Def Down
function cm.confilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)==Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_ONFIELD,0,nil)
end
cm.cost=RD.CostSendOnFieldToGrave(cm.costfilter,1,3,false,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		local down=e:GetLabel()*-1000
		RD.AttachAtkDef(e,g:GetFirst(),down,down,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end