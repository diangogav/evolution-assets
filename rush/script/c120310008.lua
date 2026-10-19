local cm,m=GetID()
local list={120310003,120225024,120310008}
cm.name="α版重建龙"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonTurn)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.costfilter(c)
	return c:IsRace(RACE_DRAGON) and (RD.IsDefense(c,900) or RD.IsDefense(c,1000))
		and c:IsAbleToGraveAsCost()
end
function cm.exfilter(c)
	return c:IsCode(list[2])
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		RD.CanDraw(aux.Stringid(m,1),tp,1)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[3])
end