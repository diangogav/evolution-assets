local cm,m=GetID()
local list={120222017,120225001}
cm.name="闪存融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,aux.FALSE,cm.spfilter,cm.matfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(cm.condition)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return aux.IsMaterialListCode(c,list[1]) or aux.IsMaterialListCode(c,list[2])
end
function cm.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.confilter(c,tp,rp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and ((rp==1-tp and c:IsReason(REASON_EFFECT)) or c==Duel.GetAttackTarget())
end
function cm.filter(c,e,tp)
	return RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP_ATTACK)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.confilter,1,nil,tp,rp)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if Duel.GetTurnPlayer()==tp then
		RD.CanSelectAndSpecialSummon(aux.Stringid(m,1),aux.NecroValleyFilter(cm.filter),1-tp,LOCATION_GRAVE,0,1,1,nil,e,POS_FACEUP_ATTACK)
	end
end