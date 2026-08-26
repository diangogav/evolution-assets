local cm,m=GetID()
cm.name="咩～界的入口"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAbleToGrave()
end
function cm.matfilter(c)
	return c:IsOnField() and c:IsRace(RACE_BEAST) and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_BEAST) and RD.IsDefense(c,1600)
end
function cm.exfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.filter,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		if RD.SendToGraveAndExists(g) then
			RD.CanFusionSummon(aux.Stringid(m,1),cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck,e,tp,POS_FACEUP,true)
		end
	end)
end