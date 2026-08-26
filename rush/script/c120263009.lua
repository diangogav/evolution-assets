local cm,m=GetID()
cm.name="元素英雄 水泡侠"
function cm.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Draw
function cm.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return RD.ConditionSummonOrSpecialSummonMainPhase(e)
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD+LOCATION_HAND,0)<=1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	RD.TargetDraw(tp,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.Draw()
end