local cm,m=GetID()
cm.name="黄昏之友 车马龙"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureZero(c,aux.Stringid(m,0),cm.sumcon)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c)
	return c:IsType(TYPE_FIELD)
end
function cm.sumcon(c,e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)>0
		or Duel.IsExistingMatchingCard(cm.sumfilter,tp,LOCATION_GRAVE,0,1,nil)
end
--Atk Up
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_GALAXY)
		and c:IsAbleToDeckOrExtraAsCost()
end
function cm.tdfilter(c)
	return not RD.IsNormalSpell(c) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,2,2)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,600,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
			RD.SendToDeckTop(sg,e,tp,REASON_EFFECT)
		end)
	end
end