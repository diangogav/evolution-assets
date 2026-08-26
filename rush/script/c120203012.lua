local cm,m=GetID()
cm.name="王家魔族·硬摇滚歌手"
function cm.initial_effect(c)
	--Tribute
	RD.CreateAdvanceCheck(c,cm.tricheck,2,20203012)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Tribute
function cm.tricheck(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_FIEND)
end
--Damage
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return RD.IsSummonTurn(c) and c:GetFlagEffect(20203012)~=0
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			local tc=g:GetFirst()
			local dam=math.abs(c:GetAttack()-tc:GetAttack())
			if dam>0 then
				Duel.Damage(1-tp,dam,REASON_EFFECT)
			end
			RD.AttachAtkDef(e,c,tc:GetAttack(),0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end