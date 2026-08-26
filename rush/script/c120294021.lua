local cm,m=GetID()
cm.name="宇宙吸食者"
function cm.initial_effect(c)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Recover
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return RD.IsLPBelowOpponent(tp,1)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not RD.IsPlayerNoDrawInThisMain(tp) or Duel.IsPlayerCanDraw(tp,1) end
	RD.TargetRecover(tp,300)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if RD.Recover()~=0 then
		if RD.IsPlayerNoDrawInThisMain(tp) then
			Duel.Draw(tp,1,REASON_EFFECT)
			local g=Duel.GetMatchingGroup(cm.exfilter,tp,0,LOCATION_MZONE,nil)
			if g:GetSum(Card.GetOriginalLevel)>=30 then
				RD.CanRecover(aux.Stringid(m,2),tp,3000)
			end
		end
	end
end