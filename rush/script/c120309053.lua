local cm,m=GetID()
local list={CARD_CODE_FuSiGiNaKoBiTo}
cm.name="相连的小人"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.filter(c)
	return c:IsCode(list[1]) and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToDeck() then
		RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			g:AddCard(c)
			RD.SendToDeckTop(g,e,tp,REASON_EFFECT)
		end)
	end
end