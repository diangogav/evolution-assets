local cm,m=GetID()
local list={120260009}
cm.name="深空警告融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,cm.matcheck,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsOnField())
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE)
end
function cm.exfilter(c)
	return c:IsOriginalCodeRule(list[1]) and c:IsLocation(LOCATION_GRAVE)
end
function cm.matcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetLocation)==1
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if mat:IsExists(cm.exfilter,1,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,nil,tp,0,LOCATION_ONFIELD,1,1,nil,function(g)
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end