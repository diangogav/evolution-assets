local cm,m=GetID()
cm.name="接合科技掷币三角龙"
function cm.initial_effect(c)
	--Coin
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_ATKCHANGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
cm.toss_coin=true
--Coin
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local res=Duel.TossCoin(tp,1)
		if res==1 then
			RD.AttachAtkDef(e,c,1500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			RD.AttachAttackNotChainTrap(e,m,c,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		else
			RD.ChangePosition(c,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
		end
	end
end