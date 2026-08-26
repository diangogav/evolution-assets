local cm,m=GetID()
cm.name="新宇宙侠·水波海豚"
function cm.initial_effect(c)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
cm.cost=RD.CostSendHandToGrave(Card.IsAbleToGraveAsCost,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		Duel.ConfirmCards(tp,g)
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		if mg:GetCount()==0 then return end
		local _,atk=mg:GetMaxGroup(Card.GetAttack)
		local filter=function(c)
			return c:IsAttackBelow(atk) and c:IsAbleToGrave()
		end
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TOGRAVE,filter,tp,0,LOCATION_HAND,1,1,nil,function(sg)
			if RD.SendToGraveAndExists(sg) then
				Duel.Damage(1-tp,500,REASON_EFFECT)
			end
		end)
		Duel.ShuffleHand(1-tp)
	end
end