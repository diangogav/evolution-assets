local cm,m=GetID()
cm.name="钢机神 镜光革新者"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.tdfilter(c,race)
	return c:IsLevelAbove(1) and c:IsRace(race) and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local race=e:GetHandler():GetRace()
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,LOCATION_GRAVE,0,1,nil,race) end
	local g=Duel.GetMatchingGroup(cm.tdfilter,tp,LOCATION_GRAVE,0,nil,race)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local filter=RD.Filter(cm.tdfilter,c:GetRace())
		RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,3,nil,function(g)
			local atk=g:GetSum(Card.GetLevel)*100
			RD.AttachAtkDef(e,c,atk,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			Duel.BreakEffect()
			if RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT) and Duel.GetOperatedGroup():GetCount()==1 then
				RD.AttachPierce(e,c,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end
		end)
	end
end