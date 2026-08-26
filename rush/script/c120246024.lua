local cm,m=GetID()
local list={120105010,120246016}
cm.name="落单猫嫉妒草"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsCode(list[1],list[2])
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return Duel.GetAttacker():IsControler(1-tp)
		and (Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_GRAVE,0,1,nil)
		or (tc and tc:IsFaceup() and tc:IsAttack(0)))
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	if Duel.NegateAttack() and tc and RD.IsCanChangePosition(tc,e,tp,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
		Duel.BreakEffect()
		if RD.ChangePosition(tc,e,tp,REASON_EFFECT)~=0 then
			local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*200
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end