local cm,m=GetID()
cm.name="云海龙 波尔卡"
function cm.initial_effect(c)
	--Union
	local e1=RD.RegisterUnionEffect(c,cm.filter,nil,nil,cm.operation)
	e1:SetCategory(e1:GetCategory()|CATEGORY_TOHAND|CATEGORY_GRAVE_ACTION)
	--Cannot Be Battle Target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(cm.atkcon)
	e2:SetValue(cm.atktg)
	c:RegisterEffect(e2)
end
--Union
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
end
function cm.thfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SEASERPENT)
		and c:IsAbleToHand()
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end)
end
--Cannot Be Battle Target
function cm.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return aux.IsUnionState(e) and not RD.IsAttacking(e)
		and ec and ec:GetControler()==e:GetHandlerPlayer()
end
function cm.atktg(e,c)
	return c:GetEquipCount()==0
end