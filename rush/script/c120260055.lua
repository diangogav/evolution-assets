local cm,m=GetID()
cm.name="爱之回返"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:GetBaseAttack()==0 and RD.IsBaseDefense(c,0) and c:IsRace(RACE_FAIRY)
end
function cm.getgroup()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	local mg=g:GetMaxGroup(Card.GetBaseAttack):Filter(Card.IsAbleToHand,nil)
	return mg
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil) and ep==tp and r==REASON_RULE
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=cm.getgroup()
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=cm.getgroup()
	if g:GetCount()>0 then
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end
end