local cm,m=GetID()
cm.name="被谋划的两败俱伤"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local b=Duel.GetAttackTarget()
	if a:IsControler(1-tp) and b and b:IsControler(tp) and b:IsPosition(POS_FACEUP_ATTACK) then
		return a:IsAbleToHand() or b:IsAbleToHand()
	end
	return false
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local b=Duel.GetAttackTarget()
	if a and b and a:IsRelateToBattle() and b:IsRelateToBattle() then
		local g=Group.FromCards(a,b):Filter(Card.IsAbleToHand,nil)
		RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
	end
end