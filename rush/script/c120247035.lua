local cm,m=GetID()
cm.name="虎死眈眈"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR+RACE_BEAST)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
		and Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsAttackPos() and RD.IsCanChangePosition(tc,e,tp,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsAttackPos()
		and RD.ChangePosition(tc,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)~=0
		and Duel.GetLP(tp)<=Duel.GetLP(1-tp) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			if Duel.Destroy(g,REASON_EFFECT)~=0 then
				Duel.BreakEffect()
				local dam=Duel.GetOperatedGroup():GetFirst():GetBaseAttack()
				Duel.Damage(1-tp,dam,REASON_EFFECT)
			end
		end)
	end
end