local cm,m=GetID()
cm.name="魔力火风暴"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function cm.filter(c)
	return c:IsFaceup() and c:GetOriginalLevel()<=6
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.ctfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cm.ctfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	RD.SelectAndDoAction(HINTMSG_DESTROY,cm.filter,tp,0,LOCATION_MZONE,1,ct,nil,function(g)
		Duel.Destroy(g,REASON_EFFECT)
	end)
end