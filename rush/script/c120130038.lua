local cm,m=GetID()
cm.name="不眠夜狂热"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.posfilter(c,e,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_AQUA) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*400)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.posfilter,e,tp)
	local g=Duel.GetMatchingGroup(filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		local ct=RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)
		Duel.Recover(tp,ct*400,REASON_EFFECT)
	end
end