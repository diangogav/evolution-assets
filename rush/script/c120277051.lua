local cm,m=GetID()
cm.name="银河混沌融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,cm.matcheck,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,2)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
function cm.spfilter(c)
	return c:IsLevel(9) and c:IsRace(RACE_GALAXY)
end
function cm.exfilter(c)
	return c:GetOriginalLevel()>=7 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE)
end
function cm.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.matcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetAttribute)==sg:GetCount()
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if mat:IsExists(cm.exfilter,2,nil) then
		RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_ONFIELD,1,2,nil,function(g)
			Duel.Destroy(g,REASON_EFFECT)
		end)
	end
end