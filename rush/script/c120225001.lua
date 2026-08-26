local cm,m=GetID()
cm.name="真红动击速龙"
function cm.initial_effect(c)
	--Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Damage
function cm.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,7,nil,function(g)
		local ct=g:GetCount()
		local c=e:GetHandler()
		if Duel.Damage(1-tp,ct*100,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			RD.AttachAtkDef(e,c,ct*100,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			Duel.BreakEffect()
			RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
		end
	end)
end