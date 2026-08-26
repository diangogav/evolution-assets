local cm,m=GetID()
local list={120247006,120207007}
cm.name="鹰身女郎3·1"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,list[1],cm.matfilter)
	--Contact Fusion
	RD.EnableContactFusion(c,aux.Stringid(m,0))
	--Change Code
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Fusion Material
cm.unspecified_funsion=true
function cm.matfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST)
end
--Change Code
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsCanChangeCode(e:GetHandler(),list[2])
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.ChangeCode(e,c,list[2],RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
	if Duel.GetFlagEffect(1-tp,FLAG_MAX_ATTACK_TWICE_NEXT_TURN)~=0 then return end
	local e1,e2=RD.CreateLimitAttackCountEffect(e,aux.Stringid(m,2),2,tp,0,1,RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e2:SetCondition(cm.atkcon)
	Duel.RegisterFlagEffect(1-tp,FLAG_MAX_ATTACK_TWICE_NEXT_TURN,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
end
function cm.atkcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end