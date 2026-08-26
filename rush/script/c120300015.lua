local cm,m=GetID()
cm.name="月力梳耳兔"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) or (c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_GALAXY)))
		and c:IsAbleToDeckOrExtraAsCost()
end
function cm.check(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsSummonTurn(e:GetHandler()) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>9
end
cm.cost=RD.CostSendGroupToDeckSort(cm.costfilter,cm.check,LOCATION_HAND+LOCATION_GRAVE,2,2,true,SEQ_DECKBOTTOM,true,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	RD.TargetDraw(tp,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.Draw()
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	RD.CreateNoEffectDamageEffect(e,aux.Stringid(m,2),cm.damval,tp,0,1,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_GALAXY))
end
function cm.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end