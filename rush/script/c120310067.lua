local cm,m=GetID()
local list={120310044,120299001}
cm.name="次元的盟友 莉天使"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Fusion Summon
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation,cm.limit)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(RD.ConditionSummonOrSpecialSummonMainPhase)
	c:RegisterEffect(e1)
end
--Fusion Summon
function cm.spfilter(c)
	return c:IsCode(list[1])
end
function cm.thfilter(c)
	return c:IsCode(list[2]) and c:IsAbleToHand()
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	RD.CanSelectAndDoAction(aux.Stringid(m,1),HINTMSG_ATOHAND,aux.NecroValleyFilter(cm.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,function(sg)
		Duel.BreakEffect()
		RD.SendToHandAndExists(sg,e,tp,REASON_EFFECT)
	end)
end
function cm.limit(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,2),RACE_ALL-RACE_CYBERSE,tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not (c:IsLevelAbove(8) and c:IsRace(RACE_CYBERSE))
end