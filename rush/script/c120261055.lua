local cm,m=GetID()
cm.name="香料忍布交织混合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_CYBERSE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_TODECK,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,1,nil,function(g)
		Duel.BreakEffect()
		RD.SendToDeckTopOrBottom(g,e,tp,REASON_EFFECT,aux.Stringid(m,2),aux.Stringid(m,3))
	end)
end