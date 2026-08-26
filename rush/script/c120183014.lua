local cm,m=GetID()
local list={120105001}
cm.name="七星道男巫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Change
function cm.filter(c,atk)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAttack(atk)
end
function cm.exfilter(c)
	return c:IsCode(list[1])
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local filter=RD.Filter(cm.filter,c:GetAttack())
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.SetBaseAtkDef(e,g:GetFirst(),0,nil,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
			RD.CanDraw(aux.Stringid(m,2),tp,1)
		end
	end)
end