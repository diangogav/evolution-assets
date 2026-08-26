local cm,m=GetID()
cm.name="交剑死哀"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return RD.IsPreviousControler(c,tp) and c==Duel.GetAttackTarget() and RD.IsPreviousAttribute(c,ATTRIBUTE_EARTH)
end
function cm.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_EARTH)
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_GRAVE,0,nil)*100
	if chk==0 then return dam>0 end
	RD.TargetDamage(1-tp,dam)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetMatchingGroupCount(cm.filter,tp,LOCATION_GRAVE,0,nil)*100
	if dam>0 and Duel.Damage(p,dam,REASON_EFFECT)~=0 and p==1-tp then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end