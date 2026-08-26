local cm,m=GetID()
cm.name="莓果新人·富饶小莓"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.exfilter(c)
	return c:GetBaseAttack()==100 and c:IsRace(RACE_AQUA)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSummonTurn(e:GetHandler()) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
cm.cost=RD.CostSendHandOrFieldToGrave(Card.IsAbleToGraveAsCost,2,2,true,nil,nil,function(g)
	if g:IsExists(cm.exfilter,1,nil) then
		return 120264027
	else
		return 0
	end
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and e:GetLabel()==120264027 then
		RD.CanDraw(aux.Stringid(m,1),tp,1)
	end
end