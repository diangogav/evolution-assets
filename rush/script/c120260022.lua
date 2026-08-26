local cm,m=GetID()
cm.name="临界服务"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.confilter(c,tp)
	return RD.IsPreviousControler(c,tp) and c==Duel.GetAttackTarget()
end
function cm.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.exfilter(c)
	return c:IsLevel(7,8) and c:IsAbleToGrave()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if RD.SelectAndSpecialSummon(aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP)~=0 then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TOGRAVE,cm.exfilter,tp,LOCATION_HAND,0,1,1,nil,function(g)
			Duel.BreakEffect()
			if RD.SendToGraveAndExists(g) then
				local tc=Duel.GetOperatedGroup():GetFirst()
				if tc:IsLocation(LOCATION_GRAVE) and tc:IsLevelAbove(1) then
					Duel.BreakEffect()
					Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
				end
			end
		end)
	end
end