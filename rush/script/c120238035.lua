local cm,m=GetID()
cm.name="恶魔盗贼-恶魔使役者"
function cm.initial_effect(c)
	--Indes Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Indes Effect
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,c,tp)
end
function cm.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and RD.IsCanAttachEffectIndes(c,tp,cm.indval)
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,2,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end)
end