local cm,m=GetID()
cm.name="梦中之钩蛱蝶"
function cm.initial_effect(c)
	--Level Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Level Down
function cm.confilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_INSECT)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(3)
end
function cm.exfilter(c)
	return c:IsFaceup() and RD.IsCanChangeRace(c,RACE_INSECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
cm.cost=RD.CostChangeSelfPosition(POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachLevel(e,g:GetFirst(),-2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,2),aux.Stringid(m,3),cm.exfilter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
			Duel.BreakEffect()
			RD.ChangeRace(e,sg:GetFirst(),RACE_INSECT,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end)
	end)
end