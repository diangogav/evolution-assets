local cm,m=GetID()
cm.name="克里斯马魔法-优雅变化"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	if not c:IsAbleToGraveAsCost() then return false end
	local b1=c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
	local b2=c:IsType(TYPE_EQUIP)
	if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,3,nil) and not Duel.IsPlayerCanDraw(tp,2) then
		return b2
	else
		return b1 or b2
	end
end
function cm.exfilter(c)
	return c:IsType(TYPE_MONSTER)
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,4,nil) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end