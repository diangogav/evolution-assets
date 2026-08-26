local cm,m=GetID()
cm.name="魔力动物鞭手"
function cm.initial_effect(c)
	--Summon Procedure
	RD.AddSummonProcedureOne(c,aux.Stringid(m,0),nil,cm.sumfilter)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Summon Procedure
function cm.sumfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
--Atk Down
function cm.costfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv-1)
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetLevel()) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local filter=RD.Filter(cm.filter,c:GetLevel())
		RD.SelectAndDoAction(aux.Stringid(m,2),filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			RD.AttachAtkDef(e,g:GetFirst(),-2000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end