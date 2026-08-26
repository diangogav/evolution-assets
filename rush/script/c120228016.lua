local cm,m=GetID()
cm.name="加农炮兵运动服士"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.confilter(c)
	return c:IsFaceup() and RD.IsDefense(c,500)
end
function cm.costfilter(c)
	return c:IsFaceup() and RD.IsDefense(c,500) and c:IsAbleToGraveAsCost()
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetDamage(1-tp,500)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Damage()~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.atkfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			Duel.BreakEffect()
			RD.AttachAtkDef(e,g:GetFirst(),-500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end