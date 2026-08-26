local cm,m=GetID()
cm.name="电子界守护者"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.costfilter(c,e,tp)
	return c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,c)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1,false)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		RD.AttachAtkDef(e,tc,300,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
end