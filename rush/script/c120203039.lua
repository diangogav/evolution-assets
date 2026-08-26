local cm,m=GetID()
local list={120151018}
cm.name="不成哥布林"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Atk Down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Down
function cm.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function cm.tdfilter(c)
	return RD.IsLegendCode(c,list[1]) and c:IsAbleToDeck()
end
cm.cost=RD.CostSendSelfToGrave()
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		RD.AttachAtkDef(e,g:GetFirst(),-500,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_TODECK,aux.NecroValleyFilter(cm.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
			Duel.BreakEffect()
			if RD.SendToDeckTop(sg,e,tp,REASON_EFFECT)~=0 then
				RD.CanSelectAndDoAction(aux.Stringid(m,3),HINTMSG_DESTROY,cm.filter,tp,0,LOCATION_MZONE,1,1,nil,function(dg)
					Duel.Destroy(dg,REASON_EFFECT)
				end)
			end
		end)
	end)
end