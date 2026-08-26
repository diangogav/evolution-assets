local cm,m=GetID()
cm.name="圣丽的冻士 格拉基耶斯"
function cm.initial_effect(c)
	--Level Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Level Up
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
function cm.tdfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
cm.cost=RD.CostSendHandOrFieldToGrave(cm.costfilter,1,6,true,nil,nil,Group.GetCount)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachLevel(e,c,1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		local ct=math.floor(e:GetLabel()/3)
		if ct>0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,cm.tdfilter,tp,0,LOCATION_ONFIELD,1,ct,nil,function(g)
				RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
			end)
		end
	end
end