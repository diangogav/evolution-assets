local cm,m=GetID()
cm.name="虚空噬骸兵·极乐鹰巨人"
function cm.initial_effect(c)
	--Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Position
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and c:IsCanTurnSet()
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1,nil,nil,function(g)
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		return 20227001
	else
		return 0
	end
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	RD.SelectAndDoAction(HINTMSG_SET,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)~=0 then
			local c=e:GetHandler()
			if c:IsFaceup() and c:IsRelateToEffect(e) then
				local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
				RD.AttachAtkDef(e,c,500,0,reset)
				if e:GetLabel()==20227001 then
					RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,1),reset)
				end
			end
		end
	end)
end