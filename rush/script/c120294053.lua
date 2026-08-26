local cm,m=GetID()
local list={120294056}
cm.name="超高速度"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_MACHINE) and RD.IsDefense(c,800)
end
function cm.exfilter(c)
	return c:IsCode(list[1])
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if Duel.IsExistingMatchingCard(cm.exfilter,tp,LOCATION_GRAVE,0,1,nil) then
		RD.AttachAtkDef(e,fc,600,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,true)
	end
end