local cm,m=GetID()
cm.name="即兴果酱音跃：P摘取！"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.costfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.exfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PSYCHO)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
cm.cost=RD.CostSendGraveToDeck(cm.costfilter,2,4)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsAttackPos() and RD.IsCanChangePosition(tc,e,tp,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and tc:IsAttackPos()
		and RD.ChangePosition(tc,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)~=0
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		local ct=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if ct>0 then
			RD.CanDraw(aux.Stringid(m,1),tp,ct)
		end
	end
end