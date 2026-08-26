local cm,m=GetID()
cm.name="暗黑魔神的引导"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_MSET)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition1)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cm.condition2)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(cm.condition3)
	c:RegisterEffect(e3)
end
--Activate
function cm.confilter1(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function cm.confilter2(c,tp)
	return c:IsFacedown() and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function cm.confilter3(c,tp)
	return c:IsFacedown() and c:IsPreviousPosition(POS_FACEUP) and c:IsControler(tp)
end
function cm.exfilter(c,tc)
	return c:IsFaceup() and c:IsAttackAbove(tc:GetBaseAttack())
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter1,1,nil,1-tp)
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter2,1,nil,1-tp)
end
function cm.condition3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter3,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_FACEDOWN,Card.IsFacedown,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		Duel.ConfirmCards(tp,g)
		local tc=g:GetFirst()
		if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil,tc)
			and Duel.SelectEffectYesNo(tp,tc,aux.Stringid(m,1)) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end)
end