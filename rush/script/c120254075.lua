local cm,m=GetID()
cm.name="双生闪亮星"
function cm.initial_effect(c)
	--Level Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Level Up
cm.trival=RD.ValueDoubleTributeAttrRace(ATTRIBUTE_LIGHT,RACE_GALAXY)
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_GALAXY) and c:IsLocation(LOCATION_GRAVE)
end
cm.cost=RD.CostSendDeckTopToGrave(1,function(g)
	return g:FilterCount(cm.costfilter,nil)
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachLevel(e,c,2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if e:GetLabel()>0 then
			RD.AttachDoubleTribute(e,c,cm.trival,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end