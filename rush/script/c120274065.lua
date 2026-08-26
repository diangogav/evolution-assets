local cm,m=GetID()
cm.name="梦中的拥抱"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,cm.exfilter,0,LOCATION_MZONE,cm.matcheck,RD.FusionToGrave,nil,nil,cm.limit)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,2)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsOnField() and c:IsFaceup()
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_INSECT)
end
function cm.exfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(9)
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()==2 and sg:IsExists(Card.IsControler,1,nil,tp)
		and sg:IsExists(Card.IsLevelBelow,1,nil,9)
end
function cm.limit(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,1),RACE_ALL-RACE_INSECT,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end