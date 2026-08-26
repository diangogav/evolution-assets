local cm,m=GetID()
cm.name="救生刀剑鱼"
function cm.initial_effect(c)
	--Atk Up
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
--Atk Up
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevel(7) and c:IsRace(RACE_FISH)
end
function cm.costfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil)
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,2,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end)
end