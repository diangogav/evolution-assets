local cm,m=GetID()
cm.name="燃尾之急"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevel(7)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	RD.TargetDamage(1-tp,600)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.Damage()~=0 and Duel.IsExistingMatchingCard(cm.exfilter,tp,0,LOCATION_MZONE,2,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			RD.SendToDeckAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end