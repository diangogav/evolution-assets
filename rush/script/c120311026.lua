local cm,m=GetID()
local list={120311026}
cm.name="暗黑融合"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.spfilter(c)
	return c:IsRace(RACE_FIEND)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if aux.IsCodeListed(fc,list[1]) then
		RD.AttachEffectIndes(e,fc,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end