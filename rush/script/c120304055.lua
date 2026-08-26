local cm,m=GetID()
local list={120304062}
cm.name="锐进防护"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.filter(c)
	return (cm.filter1(c) or cm.filter2(c)) and c:IsAbleToHand()
end
function cm.filter1(c)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)
		and RD.IsDefense(c,1000)
end
function cm.filter2(c)
	return c:IsCode(list[1])
end
function cm.exfilter(c,tp)
	return c:IsFaceup() and RD.IsCanAttachEffectIndes(c,tp,cm.indval)
end
function cm.check(g)
	if g:GetCount()<2 then return true end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return (cm.filter1(tc1) and cm.filter2(tc2)) or (cm.filter1(tc2) and cm.filter2(tc1))
end
cm.cost=RD.CostSendHandToDeckBottom(Card.IsAbleToDeckAsCost,1,1,false)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectGroupAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),cm.check,tp,LOCATION_GRAVE,0,1,2,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			local filter=RD.Filter(cm.exfilter,tp)
			RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),filter,tp,LOCATION_MZONE,0,1,1,nil,function(sg)
				Duel.BreakEffect()
				RD.AttachEffectIndes(e,sg:GetFirst(),cm.indval,aux.Stringid(m,3),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end)
		end
	end)
end