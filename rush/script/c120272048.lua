local cm,m=GetID()
local list={120209001}
cm.name="穿越侍星云融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
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
	return c:IsRace(RACE_GALAXY) and c:IsAbleToGrave()
end
function cm.matfilter(c)
	return c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return aux.IsMaterialListCode(c,list[1])
end
function cm.exfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.matcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsOnField,nil)==1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,cm.filter,tp,LOCATION_HAND,0,1,1,nil,function(g)
		if RD.SendToGraveAndExists(g) and Duel.GetFusionMaterial(tp):IsExists(cm.matfilter,1,nil) then
			RD.CanFusionSummon(aux.Stringid(m,1),cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,cm.matcheck,RD.FusionToDeck,e,tp,POS_FACEUP,true)
		end
	end)
end
