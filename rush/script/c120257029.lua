local cm,m=GetID()
local list={120155000}
cm.name="念力震慑者·电脑增幅"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Indes
cm.indval=RD.ValueEffectIndesType(0,TYPE_TRAP)
function cm.filter(c)
	return c:IsRace(RACE_MACHINE)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanAttachEffectIndes(e:GetHandler(),tp,cm.indval)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		local ct=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_GRAVE,0,nil)
		if ct>0 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(m,2)) then
			RD.AttachAtkDef(e,c,ct*100,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end