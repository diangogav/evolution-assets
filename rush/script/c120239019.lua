local cm,m=GetID()
local list={120239050,120239049,120239048}
cm.name="辉钢超龙 毁灭洋渊龙［L］"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--To Hand (Normal)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
	--To Hand (MaximumMode)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(m,2))
	e2:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_XMATERIAL)
	e2:SetLabel(m)
	c:RegisterEffect(e2)
end
--To Hand
function cm.thfilter(c)
	return c:IsCode(list[1],list[2]) and c:IsAbleToHand()
end
function cm.exfilter(c)
	return c:IsCode(list[3]) and c:IsAbleToHand()
end
cm.cost=RD.CostPayLP(500)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	if RD.IsMaximumMode(e:GetHandler()) then
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) and RD.IsMaximumMode(e:GetHandler()) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.exfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
				RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
			end)
		end
	end)
end