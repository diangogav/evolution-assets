local cm,m=GetID()
cm.name="UMP 天空大戟"
function cm.initial_effect(c)
	--Direct Attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Direct Attack
function cm.filter(c,e,tc)
	return c:IsType(TYPE_UNION) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PLANT)
		and RD.CheckUnionEquip(e,tc,c)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsAbleToEnterBP()
		and RD.IsCanAttachDirectAttack(c)
		and RD.IsSummonOrSpecialSummonMainPhase(c)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachDirectAttack(e,c,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			local filter=RD.Filter(cm.filter,e,c)
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_EQUIP,aux.NecroValleyFilter(filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
				RD.UnionEquip(tp,c,g:GetFirst())
			end)
		end
	end
end