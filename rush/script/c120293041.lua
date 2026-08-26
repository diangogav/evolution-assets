local cm,m=GetID()
cm.name="消除黑暗的剑"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsAttack(500) and RD.IsDefense(c,1000) and c:IsAbleToHand()
end
function cm.posfilter(c,e,tp)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
		if RD.SendToHandAndExists(g,e,tp,REASON_EFFECT) then
			local filter=RD.Filter(cm.posfilter,e,tp)
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_POSCHANGE,filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
				Duel.BreakEffect()
				RD.ChangePosition(sg,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
			end)
		end
	end)
end