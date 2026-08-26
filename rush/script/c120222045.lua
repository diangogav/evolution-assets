local cm,m=GetID()
cm.name="交食"
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
function cm.filter1(c,e,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(cm.filter2,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
function cm.filter2(c,lv)
	return c:IsFaceup() and c:IsLevel(lv)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter1,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		local tc=g:GetFirst()
		local filter=RD.Filter(cm.filter2,tc:GetLevel())
		RD.SelectAndDoAction(HINTMSG_DESTROY,filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
			sg:AddCard(tc)
			Duel.Destroy(sg,REASON_EFFECT)
		end)
	end)
end