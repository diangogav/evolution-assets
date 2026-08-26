local cm,m=GetID()
local list={120105010,120246016}
cm.name="落单集会"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
function cm.costfilter(c)
	if not (c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGraveAsCost()) then return false end
	local ct=Duel.GetMatchingGroupCount(cm.exfilter,tp,LOCATION_GRAVE,0,nil)
	if ct==1 then return Duel.IsPlayerCanDraw(tp,2) or not cm.exfilter(c) end
	if ct>=2 then return Duel.IsPlayerCanDraw(tp,2) end
	return true
end
function cm.exfilter(c)
	return c:IsCode(list[1],list[2])
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,2,nil) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end