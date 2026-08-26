local cm,m=GetID()
local list={120145000}
cm.name="惑乱的骸骨恶魔"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND+LOCATION_GRAVE)
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Change Code
function cm.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND) and c:IsAbleToGraveAsCost()
end
function cm.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_MAXIMUM) and c:IsLevelBelow(8)
		and c:IsControlerCanBeChanged()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[1])
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[1],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_CONTROL,cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			Duel.GetControl(g:GetFirst(),tp)
		end)
	end
end