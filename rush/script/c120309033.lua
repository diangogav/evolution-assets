local cm,m=GetID()
local list={120309030,120309031,120309034}
cm.name="符电探访"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsCode(list[1],list[2],list[3]) and c:IsAbleToHand()
end
function cm.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil,function(sg)
				if RD.SendToDeckAndExists(sg,e,tp,REASON_EFFECT,cm.exfilter,1,nil) then
					RD.CanSelectAndDoAction(aux.Stringid(m,2),aux.Stringid(m,3),Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,function(g)
						Duel.BreakEffect()
						RD.AttachAtkDef(e,g:GetFirst(),-600,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					end)
				end
			end)
		end
	end)
end