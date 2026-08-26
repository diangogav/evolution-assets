local cm,m=GetID()
local list={120304021}
cm.name="魔缠龙的诅咒"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_POSITION)
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
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cm.spfilter(c,e,tp)
	return c:IsRace(RACE_WYRM) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_DEFENSE)
end
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.posfilter(c,e,tp)
	return c:IsFaceup() and RD.IsCanChangePosition(c,e,tp,REASON_EFFECT) and c:IsCanTurnSet()
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,function(g)
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
			if RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,2,nil,e,POS_FACEUP_DEFENSE,true)~=0
				and RD.IsOperatedGroupExists(cm.exfilter,1,nil) then
				local filter=RD.Filter(cm.posfilter,e,tp)
				RD.CanSelectAndDoAction(aux.Stringid(m,2),HINTMSG_SET,filter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
					RD.ChangePosition(sg,e,tp,REASON_EFFECT,POS_FACEDOWN_DEFENSE)
				end)
			end
		end
	end)
end