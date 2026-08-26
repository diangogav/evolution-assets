local cm,m=GetID()
cm.name="幻击龙 齿车戒幻龙"
function cm.initial_effect(c)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Down
function cm.costfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(7)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,0,LOCATION_MZONE,1,2,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,-1500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			--Extra Attack
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_BATTLE_DESTROYING)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCondition(aux.bdcon)
			e1:SetOperation(cm.chop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			local e2=RD.AttachExtraAttackMonster(e,c,1,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetCondition(cm.atkcon)
		end
	end)
end
function cm.chop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(20145025,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
function cm.atkcon(e)
	return e:GetHandler():GetFlagEffect(20145025)~=0
end