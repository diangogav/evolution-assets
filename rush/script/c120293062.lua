local cm,m=GetID()
local list={120293060,CARD_CODE_OTS}
cm.name="外宇宙 戴维尔加魔愿"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND)
	RD.EnableChangeCode(c,list[2],LOCATION_GRAVE)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.thfilter(c)
	return c:IsLevel(10) and c:IsCode(list[2]) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return not RD.MaximumMode(e)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		local c=e:GetHandler()
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
			and c:IsFaceup() and c:IsRelateToEffect(e)
			and RD.IsCanChangeRace(c,RACE_GALAXY)
			and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,1)) then
			Duel.BreakEffect()
			RD.ChangeRace(e,c,RACE_GALAXY,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end)
end