local cm,m=GetID()
cm.name="讹魔谎装之不老实蒂斯"
function cm.initial_effect(c)
	--Atk & Def Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk & Def Up
function cm.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_MAXIMUM) and c:IsType(TYPE_EFFECT) and c:IsAttackAbove(100)
end
cm.cost=RD.CostSendDeckTopToGrave(1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			local tc=g:GetFirst()
			RD.AttachAtkDef(e,c,tc:GetAttack(),0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			RD.AttachNoBattleDamage(e,c,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end)
	end
end