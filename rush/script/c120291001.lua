local cm,m=GetID()
local list={120291001}
cm.name="邪帝 盖乌斯"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Deck
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsAdvanceSummonTurn(e:GetHandler())
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,function(g)
		local tc=g:GetFirst()
		local ex=tc:IsFaceup() and tc:GetOriginalAttribute()==ATTRIBUTE_DARK
		if RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)~=0 and ex then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,1),m,tp,list[1])
end