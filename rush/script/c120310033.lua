local cm,m=GetID()
local list={120145044,120310033}
cm.name="美之里的栗子猫"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Confirm Card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Confirm Card
function cm.setfilter(c)
	return c:IsCode(list[1]) and c:IsSSetable()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 then
		Duel.ConfirmDecktop(tp,3)
		Duel.SortDecktop(tp,tp,3)
		if RD.CanSelectAndSet(aux.Stringid(m,1),aux.NecroValleyFilter(cm.setfilter),tp,LOCATION_GRAVE,0,1,2,nil,e,true)~=0 then
			--Change Damage
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(m,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,0)
			e1:SetValue(cm.damval)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,3),m,tp,list[2])
		end
	end
end
function cm.damval(e,re,val,r,rp,rc)
	if re and re:GetHandler():IsCode(list[1]) then
		Duel.Hint(HINT_CARD,0,m)
		return 0
	else
		return val
	end
end