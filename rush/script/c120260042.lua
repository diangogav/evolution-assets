local cm,m=GetID()
cm.name="可爱之天童"
function cm.initial_effect(c)
	--Atk Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Atk Up
function cm.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()==0
end
function cm.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(aux.Stringid(m,1),cm.filter,tp,LOCATION_MZONE,0,1,3,nil,function(g)
		g:ForEach(function(tc)
			RD.AttachAtkDef(e,tc,600,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
		local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
		if mg:GetCount()>0 and mg:GetSum(Card.GetAttack)==0 then
			RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_TODECK,cm.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil,function(sg)
				RD.SendToDeckBottom(sg,e,tp,REASON_EFFECT)
			end)
		end
	end)
end