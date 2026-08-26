local cm,m=GetID()
cm.name="填埋盾"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
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
	return c:IsType(TYPE_FIELD) and c:IsAbleToDeckAsCost()
end
function cm.upfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendGraveToDeckBottom(cm.costfilter,1,1)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return RD.IsCanChangePosition(tc,e,tp,REASON_EFFECT) and tc:IsCanTurnSet() end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and RD.ChangePosition(tc,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),aux.Stringid(m,2),cm.upfilter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
			RD.AttachAtkDef(e,g:GetFirst(),500,500,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end)
	end
end