local cm,m=GetID()
cm.name="深渊杀戮者·提亚玛特女王"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsType(TYPE_MAXIMUM) and c:IsRace(RACE_SEASERPENT)
end
function cm.thfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
function cm.costcheck(g,e,tp)
	return g:IsExists(cm.exfilter,1,nil)
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.costcheck,1,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
		local sg,g=RD.RevealDeckTopAndCanSelect(tp,5,aux.Stringid(m,2),HINTMSG_ATOHAND,cm.thfilter,1,3)
		if sg:GetCount()>0 then
			Duel.DisableShuffleCheck()
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
			Duel.ShuffleHand(tp)
		end
		local ct=g:GetCount()
		if ct>0 then
			Duel.SortDecktop(tp,tp,ct)
			RD.SendDeckTopToBottom(tp,ct)
		end
	end
end