local cm,m=GetID()
cm.name="兽机界霸者 战王卡车狮虎王"
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
function cm.costfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToGraveAsCost()
end
cm.cost=RD.CostSendMZoneToGrave(cm.costfilter,2,2,true,function(g)
	return g:GetSum(Card.GetLevel)
end)
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=e:GetLabel()*100
		local reset1=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		local reset2=RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END
		RD.AttachAtkDef(e,c,atk,0,reset1)
		RD.AttachCannotSelectBattleTarget(e,c,cm.atlimit,aux.Stringid(m,2),reset2)
		RD.AttachCannotDirectAttack(e,c,aux.Stringid(m,3),reset2)
		RD.AttachAttackAll(e,c,1,aux.Stringid(m,4),reset1)
	end
	RD.CreateHintEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateOnlyThisAttackEffect(e,20145031,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
end
function cm.atlimit(e,c)
	return c:IsDefensePos()
end