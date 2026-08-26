local cm,m=GetID()
cm.name="生死一线性海牛侍"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetRecover(tp,800)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Recover()~=0 then
		local g=Duel.GetDecktopGroup(tp,1)
		if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			Duel.ConfirmCards(1-tp,g)
			local tc=g:GetFirst()
			if tc:IsType(TYPE_NORMAL) and tc:IsRace(RACE_GALAXY) and tc:IsAttackAbove(1600) then
				Duel.NegateAttack()
			end
			Duel.ShuffleHand(tp)
		end
	end
end