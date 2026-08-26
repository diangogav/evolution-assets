local cm,m=GetID()
local list={120208002,120222025}
cm.name="混沌闪亮星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
cm.trival1=RD.ValueDoubleTributeCode(list[1])
cm.trival2=RD.ValueDoubleTributeCode(list[2])
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
		and c:IsAbleToGraveAsCost()
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.Draw()
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		RD.AttachDoubleTribute(e,c,cm.trival1,aux.Stringid(m,1),reset)
		RD.AttachDoubleTribute(e,c,cm.trival2,aux.Stringid(m,2),reset)
	end
end