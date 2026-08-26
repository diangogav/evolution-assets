local cm,m=GetID()
cm.name="步步逼近的足音"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function cm.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function cm.setcheck(g,ft)
	local ct=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return ct<=1 and g:GetCount()-ct<=ft
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter,tp,LOCATION_MZONE,0,1,nil) and ep~=tp and r==REASON_RULE
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		Duel.ConfirmCards(tp,g)
		local ft=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
		local og=g:Filter(cm.setfilter,nil)
		if ft>0 and og:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
			local sg=RD.Select(HINTMSG_SET,tp,og,cm.setcheck,false,1,3,ft)
			local dam=Duel.SSet(1-tp,sg)
			Duel.Damage(1-tp,dam*300,REASON_EFFECT)
		end
	end
	Duel.ShuffleHand(1-tp)
end