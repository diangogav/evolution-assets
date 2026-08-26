local cm,m=GetID()
local list={120304042,120304043}
cm.name="锐进装备"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
--Activate
function cm.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsOnField() and c:IsAbleToDeck()
end
function cm.spfilter(c)
	return c:IsCode(list[1],list[2])
end
function cm.exfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.confilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function cm.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,1-tp)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_DESTROY,cm.desfilter,tp,0,LOCATION_MZONE,1,1,nil,function(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end)
end