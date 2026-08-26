local cm,m=GetID()
cm.name="融合术解除"
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
--Activate
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
function cm.spfilter(c,e,tp,fc)
	return aux.IsMaterialListCode(fc,c:GetCode()) and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end
function cm.check(g,fc)
	return fc:CheckFusionMaterial(g,nil,PLAYER_NONE,true)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	RD.SelectAndDoAction(HINTMSG_TODECK,cm.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,function(g)
		local tc=g:GetFirst()
		local min,max=aux.GetMaterialListCount(tc)
		local ex=tc:IsSummonType(SUMMON_TYPE_FUSION) and not tc.unspecified_funsion and min>0 and min==max
		if RD.SendToDeckAndExists(tc,e,tp,REASON_EFFECT) and ex then
			local sump=tc:GetControler()
			local filter=RD.Filter(cm.spfilter,e,sump,tc)
			local check=RD.Check(cm.check,tc)
			RD.CanSelectGroupAndSpecialSummon(aux.Stringid(m,1),filter,check,sump,LOCATION_GRAVE,0,min,min,nil,e,POS_FACEUP)
		end
	end)
end