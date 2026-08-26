local cm,m=GetID()
cm.name="岩浆按摩师G"
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
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,4,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),e:GetLabel()*500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end