local cm,m=GetID()
cm.name="重力增龙"
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
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetMatchingGroupCount(cm.atkfilter,tp,LOCATION_MZONE,0,nil)*400
	if atk==0 then return end
	RD.SelectAndDoAction(aux.Stringid(m,1),Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end