local cm,m=GetID()
cm.name="念力妙语融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,nil,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_PSYCHO)
end
function cm.exfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
function cm.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(g)
			Duel.BreakEffect()
			RD.SendToHandAndExists(g,e,tp,REASON_EFFECT)
		end)
	end
end