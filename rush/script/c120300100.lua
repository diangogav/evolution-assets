local cm,m=GetID()
local list={120300100}
cm.name="宇宙膛室之欲望淘气鬼"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
cm.cost=RD.CostPayLP(500)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	RD.TargetDraw(tp,3)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Draw()~=0 then
		RD.SelectAndDoAction(HINTMSG_TODECK,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil,function(g)
			Duel.BreakEffect()
			RD.SendToDeckBottom(g,e,tp,REASON_EFFECT)
		end)
	end
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,1),m,tp,list[1])
end