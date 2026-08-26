local cm,m=GetID()
cm.name="符电一闪"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.costfilter(c)
	return (cm.costfilter1(c) or cm.costfilter2(c)) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.costfilter1(c)
	return c:IsRace(RACE_CYBERSE)
end
function cm.costfilter2(c)
	return not c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER)
end
function cm.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(8) and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
		and c:IsCanTurnSet()
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
		and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_CYBERSE)
end
function cm.check(g)
	return g:IsExists(cm.costfilter1,1,nil) and g:IsExists(cm.costfilter2,1,nil)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
cm.cost=RD.CostSendGraveSubToDeck(cm.costfilter,cm.check,2,2)
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_MZONE,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_SET,filter,tp,0,LOCATION_MZONE,1,1,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)~=0
			and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.SelectEffectYesNo(tp,g:GetFirst(),aux.Stringid(m,1)) then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end)
end