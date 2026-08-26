local cm,m=GetID()
local list={120140009}
cm.name="左手持剑右手持盾"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.thfilter(c)
	return RD.IsLegendCode(c,list[1]) and c:IsAbleToHand()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	return tc:IsControler(1-tp) and tc:IsLevelBelow(9) and RD.IsCanChangeDef(tc)
		and bc and bc:IsAttackPos() and RD.IsCanChangeDef(bc)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if tc:IsRelateToBattle() and tc:IsFaceup() and RD.IsCanChangeDef(tc)
		and bc:IsRelateToBattle() and bc:IsFaceup() and RD.IsCanChangeDef(bc) then
		RD.SwapBaseAtkDef(e,tc,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.SwapBaseAtkDef(e,bc,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			Duel.BreakEffect()
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end