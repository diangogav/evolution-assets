local cm,m=GetID()
cm.name="隐性营销魔法"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c,e,tp)
	if not c:IsAbleToGraveAsCost() then return false end
	if RD.IsLPBelow(tp,1000) then return Duel.IsPlayerCanDraw(tp,2) or not c:IsType(TYPE_SPELL) end
	return true
end
cm.cost=RD.CostSendHandToGrave(cm.costfilter,1,1,nil,nil,function(g)
	return g:GetFirst():GetType()
end)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetDraw(tp,1)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 and e:GetLabel()&TYPE_SPELL==TYPE_SPELL and RD.IsLPBelow(tp,1000) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end