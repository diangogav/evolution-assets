local cm,m=GetID()
cm.name="洗净的圣布老人"
function cm.initial_effect(c)
	--Draw & Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw & Recover
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(1-tp,ct) end
	RD.TargetDraw(1-tp,ct)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=RD.Draw(nil,Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE))
	if ct>0 then
		Duel.BreakEffect()
		Duel.Recover(tp,ct*300,REASON_EFFECT)
	end
end