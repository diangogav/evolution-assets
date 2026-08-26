local cm,m=GetID()
cm.name="火面浓抽浓厚返之术"
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
function cm.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PYRO)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PYRO)
end
function cm.max(e,tp,eg,ep,ev,re,r,rp)
	local ct1=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_GRAVE,0,nil)
	local ct2=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	return math.min(ct1,ct2)
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,cm.max,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	RD.TargetDraw(tp,ct)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil) then
		RD.CanDraw(aux.Stringid(m,1),tp,1)
	end
end