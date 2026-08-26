local cm,m=GetID()
local list={CARD_CODE_OTS}
cm.name="破界王帝 外宇宙界愿［L］"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(m)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Indes
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.exfilter(c)
	return c:IsFaceup() and RD.IsCanChangeRace(c,RACE_FAIRY)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.MaximumMode(e) and RD.IsCanAttachEffectIndes(e:GetHandler(),tp,cm.indval)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,2),aux.Stringid(m,3),cm.exfilter,tp,0,LOCATION_MZONE,1,3,nil,function(g)
			g:ForEach(function(tc)
				RD.ChangeRace(e,tc,RACE_FAIRY,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end)
	end
end