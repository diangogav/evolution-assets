local cm,m=GetID()
cm.name="究极的青眼传说"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,cm.matfilter,cm.spfilter,nil,0,0,cm.matcheck,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(2,3)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.matfilter(c)
	return c:IsRace(RACE_DRAGON)
end
function cm.spfilter(c)
	return c:IsLevelAbove(10) and c:IsRace(RACE_DRAGON)
end
function cm.matcheck(tp,sg,fc)
	return sg:GetCount()<=3
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	RD.AttachEffectIndes(e,fc,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
end