local cm,m=GetID()
local list={120196050}
cm.name="虚空噬骸兵·后勤兵"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Set
function cm.costfilter(c,e,tp)
	return not c:IsPublic() and c:IsLevelAbove(7) and c:IsRace(RACE_GALAXY)
end
function cm.setfilter(c)
	return c:IsCode(list[1]) and c:IsSSetable()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
function cm.thfilter(c)
	return c:IsLevel(8) and c:IsRace(RACE_GALAXY) and c:IsAbleToHand()
end
cm.cost=RD.CostShowHand(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cm.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSet(aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)~=0
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,0,LOCATION_MZONE,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end)
	end
end