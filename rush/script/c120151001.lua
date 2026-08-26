local cm,m=GetID()
cm.name="超魔旗舰 大霸道王［L］"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(m)
	e1:SetCondition(RD.MaximumMode)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,c)
end
function cm.filter(c)
	return c:IsLevelAbove(1)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		if Duel.Damage(1-tp,tc:GetLevel()*100,REASON_EFFECT)~=0
			and tc:IsAbleToHand()
			and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
			RD.SendToHandAndExists(tc,e,tp,REASON_EFFECT)
		end
	end)
end