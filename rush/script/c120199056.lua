local cm,m=GetID()
cm.name="返回！饭悔！！"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsLevelBelow(6) and c:IsRace(RACE_PSYCHO) and c:IsAttackAbove(1)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return tc:IsControler(1-tp) and tc:IsFaceup() and tc:IsLevelAbove(6)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		local atk=tc:GetAttack()
		if atk>0 and Duel.Recover(tp,atk,REASON_EFFECT)>=1000
			and tc:IsAbleToHand()
			and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
			RD.SendToHandAndExists(tc,e,tp,REASON_EFFECT)
		end
	end)
end