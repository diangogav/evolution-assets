local cm,m=GetID()
local list={120145014,120120042,120105014}
cm.name="火星心岩浆妈妈"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Position
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_SPELLCASTER)
end
function cm.posfilter(c,e,tp)
	return (c:IsFaceup() or c:IsControler(1-tp)) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.thfilter(c)
	return c:IsCode(list[1],list[2],list[3]) and c:IsAbleToHand()
end
function cm.check(g)
	if g:IsExists(cm.exfilter,2,nil) then
		return g:GetCount()==2 or g:GetCount()==4
	else
		return g:GetCount()==4
	end
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.check,2,4)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT)~=0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10 then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,4,nil,function(g)
				RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
			end)
		end
	end)
end