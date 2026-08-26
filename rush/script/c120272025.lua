local cm,m=GetID()
local list={120205026}
cm.name="舞踊的惠雷之精灵"
function cm.initial_effect(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.check(g)
	return g:GetClassCount(Card.GetControler)==2
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSummonTurn(e:GetHandler()) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then return g:GetClassCount(Card.GetControler)==2 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(Card.IsAbleToDeck),cm.check,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil,function(g)
		if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)<=5 then
			RD.CanDraw(aux.Stringid(m,1),tp,1,true)
		end
	end)
end