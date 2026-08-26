local cm,m=GetID()
cm.name="高天矮星"
function cm.initial_effect(c)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--To Grave
function cm.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeFusionMaterial()
end
function cm.check(g)
	return g:GetClassCount(Card.GetRace)==g:GetCount()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TOGRAVE,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil,function(g)
		if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
		RD.CanSelectGroupAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,aux.NecroValleyFilter(cm.filter),cm.check,tp,LOCATION_GRAVE,0,3,3,nil,function(sg)
			if RD.SendToDeckAndExists(sg,e,tp,REASON_EFFECT) then
				RD.CanFusionSummon(aux.Stringid(m,2),cm.matfilter,cm.spfilter,cm.exfilter,0,LOCATION_MZONE,nil,RD.FusionToGrave,e,tp,POS_FACEUP)
			end
		end)
	end)
end