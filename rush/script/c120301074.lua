local cm,m=GetID()
local list={120301074}
cm.name="幻惑之光"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
		and Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function cm.filter(c,attr)
	return c:IsFaceup() and not c:IsAttribute(attr)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsPlayerNoActivateInThisTurn(tp,list[1])
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.costfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return g:GetCount()>0 end
	local attr=0
	local tc=g:GetFirst()
	while tc do
		attr=attr|tc:GetAttribute()
		tc=g:GetNext()
	end
	e:SetLabel(Duel.AnnounceAttribute(tp,1,attr))
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	local filter=RD.Filter(cm.filter,attr)
	RD.SelectAndDoAction(aux.Stringid(m,1),filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.ChangeAttribute(e,g:GetFirst(),attr,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanTurnSet()
		and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,2)) then
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end