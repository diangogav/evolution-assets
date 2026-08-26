local cm,m=GetID()
cm.name="沉默学习"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsLevelAbove(5)
end
function cm.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function cm.tdfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToDeck()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.confilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetRace)>=3
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_SZONE,1,nil)
		and Duel.IsExistingMatchingCard(cm.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_FACEDOWN,cm.filter,tp,0,LOCATION_SZONE,1,1,nil,function(g)
		Duel.ConfirmCards(tp,g)
		if g:GetFirst():IsType(TYPE_TRAP) then
			RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
				if RD.SendToDeckBottom(sg,e,tp,REASON_EFFECT)~=0 then
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end)
		end
	end)
end