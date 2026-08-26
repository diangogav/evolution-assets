local cm,m=GetID()
cm.name="起动指令 齿轮武力"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c)
	return c:IsFaceup() and c:IsLevelAbove(4) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function cm.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevelBelow(8)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cm.confilter,tp,LOCATION_MZONE,0,nil)
	return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==ct
		and Duel.GetAttacker():IsControler(1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ct==0 then return end
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter,tp,0,LOCATION_MZONE,1,ct,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end