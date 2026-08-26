local cm,m=GetID()
local list={120300006}
cm.name="虚空精灵·仙女蚂蚁"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Summon Procedure
	RD.AddSummonProcedureZero(c,aux.Stringid(m,0),cm.sumcon)
	--Extra Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c)
	return c:IsRace(RACE_GALAXY)
end
function cm.sumcon(c,e,tp)
	return Duel.IsExistingMatchingCard(cm.sumfilter,tp,LOCATION_GRAVE,0,3,nil)
end
--Extra Tribute
cm.trival=RD.ValueDoubleTributeAttrRace(nil,RACE_GALAXY)
function cm.thfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanAttachDoubleTribute(e:GetHandler(),cm.trival)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachDoubleTribute(e,c,cm.trival,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,3),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end