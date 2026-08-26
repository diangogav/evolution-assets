local cm,m=GetID()
cm.name="宇宙姬的嬉戏"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function cm.check(g,e,tp)
	return g:IsExists(cm.costfilter,2,nil)
end
cm.cost=RD.CostSendHandSubToGrave(Card.IsAbleToGraveAsCost,cm.check,3,3)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,2,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0
			and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=2 then
			RD.CanDraw(aux.Stringid(m,1),tp,2,true)
		end
	end)
end