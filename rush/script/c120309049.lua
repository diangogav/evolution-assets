local cm,m=GetID()
cm.name="死之罪宝-濡血蝠"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_SPELLCASTER)
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(100)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		RD.AttachEffectIndes(e,tc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		RD.CanSelectAndDoAction(aux.Stringid(m,3),aux.Stringid(m,4),cm.atkfilter,tp,0,LOCATION_MZONE,1,3,nil,function(sg)
			Duel.BreakEffect()
			local atk=tc:GetAttack()
			sg:ForEach(function(tc)
				RD.AttachAtkDef(e,tc,-atk,0,RESET_EVENT+RESETS_STANDARD)
			end)
			local dg=sg:Filter(Card.IsAttack,nil,0)
			if dg:GetCount()>0 then
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end)
	end)
end