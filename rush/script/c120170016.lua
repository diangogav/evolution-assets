local cm,m=GetID()
cm.name="灰霸炎神 烈破火神［R］"
function cm.initial_effect(c)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(m)
	e1:SetCondition(RD.MaximumMode)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Down
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		RD.AttachAtkDef(e,tc,tc:GetLevel()*-100,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		Duel.BreakEffect()
		Duel.Damage(1-tp,tc:GetLevel()*100,REASON_EFFECT)
	end)
end