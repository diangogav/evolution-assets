local cm,m=GetID()
cm.name="月力吱吱鸟"
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
function cm.costfilter(c)
	return c:IsAbleToDeckOrExtraAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
function cm.max(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerCanDraw(tp,2) then
		return 2
	else
		return 1
	end
end
cm.cost=RD.CostSendMatchToDeckSort(cm.costfilter,LOCATION_HAND+LOCATION_ONFIELD,1,cm.max,true,SEQ_DECKBOTTOM,false,true,nil,nil,Group.GetCount)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,e:GetLabel())
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.Draw()
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateCannotActivateEffect(e,aux.Stringid(m,1),cm.aclimit,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not (tc:IsAttribute(ATTRIBUTE_EARTH) and tc:IsRace(RACE_GALAXY))
end