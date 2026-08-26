local cm,m=GetID()
local list={120271074}
cm.name="起始之星域"
function cm.initial_effect(c)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_HAND+LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.costfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_NORMAL) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1,nil,nil,function(g)
	if g:IsExists(Card.IsType,1,nil,TYPE_FUSION) then
		return 1
	else
		return 0
	end
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return RD.IsCanChangePosition(tc,e,tp,REASON_EFFECT) and tc:IsCanTurnSet() end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and RD.ChangePosition(tc,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)~=0
		and e:GetLabel()==1 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil,function(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end)
	end
end