local cm,m=GetID()
cm.name="离别之风"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c)
	return c:IsFaceup() and RD.IsUnionMonsterCard(c) and c:IsAbleToGrave()
end
function cm.exfilter(c)
	return c:IsRace(RACE_SEASERPENT) and c:IsLocation(LOCATION_GRAVE)
end
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
		and c:IsCanTurnSet()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.filter,tp,LOCATION_ONFIELD,0,1,1,nil,function(g)
		if RD.SendToGraveAndExists(g,cm.exfilter,1,nil) then
			local filter=RD.Filter(cm.posfilter,e,tp)
			RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_SET,filter,tp,0,LOCATION_MZONE,1,2,nil,function(sg)
				RD.ChangePosition(sg,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)
			end)
		end
	end)
end