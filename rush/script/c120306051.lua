local cm,m=GetID()
cm.name="健康欣快感！"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_CURRENT_LEVEL_GREATER,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,nil,cm.limit)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM)
	e1:SetLabel(1,1)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField()
		and c:IsLevelAbove(7) and c:IsRace(RACE_PYRO) and RD.IsDefense(c,1300)
end
function cm.spfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_PYRO)
end
function cm.limit(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateRaceCannotAttackEffect(e,aux.Stringid(m,1),RACE_ALL-RACE_PYRO,tp,1,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end