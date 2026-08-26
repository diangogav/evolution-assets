local cm,m=GetID()
cm.name="虚钢演机乱流"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.confilter1(c)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and RD.IsDefense(c,500)
end
function cm.confilter2(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c,e,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT)
end
function cm.exfilter(c)
	return c:IsType(TYPE_NORMAL)
end
function cm.desfilter(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.confilter1,tp,LOCATION_GRAVE,0,1,nil)
		and eg:IsExists(cm.confilter2,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local filter=RD.Filter(cm.filter,e,tp)
	RD.SelectAndDoAction(HINTMSG_POSCHANGE,filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		if RD.ChangePosition(g,e,tp,REASON_EFFECT,POS_FACEUP_DEFENSE)~=0 then
			local sg=Duel.GetMatchingGroup(cm.exfilter,tp,LOCATION_GRAVE,0,nil)
			local race=RD.GroupBor(sg,Card.GetRace)
			if race~=0 then
				local desfilter=RD.Filter(cm.desfilter,race)
				RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(dg)
					Duel.BreakEffect()
					Duel.Destroy(dg,REASON_EFFECT)
				end)
			end
		end
	end)
end