local cm,m=GetID()
local list={120293053,120311013}
cm.name="澄极精 秋英宇宙星"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Material
	RD.AddFusionProcedure(c,cm.matfilter,cm.matfilter)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
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
	return c:IsRace(RACE_GALAXY) and c:IsAttack(900)
end
--Atk Up
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.thfilter(c)
	return c:IsCode(list[1]) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSpecialSummonMainPhase(e:GetHandler())
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.AttachAtkDef(e,c,400,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.AttachEffectIndes(e,c,cm.indval,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
			RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
		end)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[2])
end