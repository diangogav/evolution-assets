local cm,m=GetID()
local list={120310015,120310014}
cm.name="疯狂犯罪者·松鼠女"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Level Change
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
--Level Change
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
function cm.thfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToHand()
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		local op=Duel.SelectOption(tp,
			aux.Stringid(m,2),
			aux.Stringid(m,3),
			aux.Stringid(m,4),
			aux.Stringid(m,5),
			aux.Stringid(m,6),
			aux.Stringid(m,7))
		local lv=3-op
		if op>2 then lv=lv-1 end
		RD.AttachLevel(e,g:GetFirst(),lv,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,8),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
			Duel.BreakEffect()
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end)
	end)
	RD.CreateCannotSpecialSummonEffect(e,aux.Stringid(m,9),aux.TRUE,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,10),m,tp,list[2])
end