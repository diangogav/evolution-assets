local cm,m=GetID()
local list={120105013}
cm.name="破灭之龙魔导士"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.costfilter(c)
	return c:IsRace(RACE_SPELLCASTER+RACE_DRAGON) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c,tp)
	return c:IsFaceup() and RD.IsCanAttachEffectIndes(c,tp,cm.indval)
end
function cm.setfilter(c)
	return c:IsCode(list[1]) and c:IsSSetable()
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,4,4)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,tp)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		RD.AttachEffectIndes(e,g:GetFirst(),cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndSet(aux.Stringid(m,3),aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
	end)
end