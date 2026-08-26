local cm,m=GetID()
local list={120293046}
cm.name="谐谑之宇宙姬"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
--Destroy
function cm.spfilter(c)
	return c:IsRace(RACE_GALAXY) and (RD.IsDefense(c,1900) or RD.IsDefense(c,2600))
end
function cm.exfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_DESTROY,nil,tp,LOCATION_MZONE,0,1,3,nil,function(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			RD.SetFusionSummonMaterialCount(e,2,9)
			RD.CanFusionSummon(aux.Stringid(m,1),aux.FALSE,cm.spfilter,cm.exfilter,LOCATION_GRAVE,0,nil,RD.FusionToDeck,e,tp,POS_FACEUP,true)
			RD.ResetFusionSummonMaterialCount(e)
		end
	end)
	RD.CreateCannotActivateSameCodeEffect(e,aux.Stringid(m,2),m,tp,list[1])
end