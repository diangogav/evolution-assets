local cm,m=GetID()
local list={120155036,120155037}
cm.name="地压的爆发"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp,re,rp)
	return c:IsPreviousPosition(POS_ATTACK) and RD.IsPreviousRace(c,RACE_PYRO)
		and RD.IsPreviousControler(c,tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c==Duel.GetAttackTarget()
			or (rp==1-tp and re and re:IsActiveType(TYPE_TRAP) and c:IsReason(REASON_EFFECT))
		)
end
function cm.spfilter(c,e,tp)
	return c:IsCode(list[1],list[2]) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_PYRO)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,tp,re,rp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)~=0
		and Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end