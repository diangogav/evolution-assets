local cm,m=GetID()
local list={120310060}
cm.name="美丽的妖魔之森"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Event
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.regcon)
	e2:SetOperation(cm.regop)
	c:RegisterEffect(e2)
	--Draw
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(cm.drcon)
	e3:SetOperation(cm.drop)
	c:RegisterEffect(e3)
end
--Event
function cm.filter(c)
	local ex=false
	if c:IsPreviousLocation(LOCATION_HAND) then
		ex=c:IsType(TYPE_SPELL+TYPE_TRAP)
	elseif c:IsPreviousLocation(LOCATION_ONFIELD) then
		ex=RD.IsPreviousType(c,TYPE_SPELL+TYPE_TRAP)
	end
	return c:IsReason(REASON_COST) and ex
end
function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsControler(tp) and eg:IsExists(cm.filter,1,nil)
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(20310060,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
end
--Draw
function cm.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(20310060)~=0 and Duel.GetFlagEffect(tp,m)==0
end
function cm.drop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(20310060)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end