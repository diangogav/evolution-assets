local cm,m=GetID()
cm.name="陷阱拆除"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_SZONE,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_FACEDOWN,cm.filter,tp,0,LOCATION_SZONE,1,1,nil,function(g)
		Duel.ConfirmCards(tp,g)
		if g:GetFirst():IsType(TYPE_TRAP) then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end)
end