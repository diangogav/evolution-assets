local cm,m=GetID()
cm.name="新宇宙侠·大地鼹鼠"
function cm.initial_effect(c)
	--To Hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Hand
function cm.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,atk) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,atk)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local filter=RD.Filter(cm.filter,c:GetAttack())
		RD.SelectAndDoAction(HINTMSG_DESTROY,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			local tc=g:GetFirst()
			local dam=math.abs(c:GetAttack()-tc:GetAttack())
			if Duel.Damage(tp,dam,REASON_EFFECT)~=0 then
				Duel.BreakEffect()
				RD.SendToHandAndExists(Group.FromCards(c,tc),e,tp,REASON_EFFECT)
				RD.SkipCurrentPhase()
			end
		end)
	end
end