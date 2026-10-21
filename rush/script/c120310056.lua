local cm,m=GetID()
local list={120310057,120310069,120310047}
cm.name="千年原人的仪式"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Change Code
	RD.EnableChangeCode(c,list[1],LOCATION_GRAVE)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,nil,cm.limit)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsAttribute(ATTRIBUTE_EARTH)
end
function cm.spfilter(c)
	return c:IsCode(list[2],list[3])
end
function cm.limit(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,m)~=0 then return end
	RD.CreateHintEffect(e,aux.Stringid(m,1),tp,1,0,RESET_PHASE+PHASE_END)
	RD.CreateAttackLimitEffect(e,cm.atktg,tp,LOCATION_MZONE,0,RESET_PHASE+PHASE_END)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end
function cm.atktg(e,c)
	return not c:IsAttribute(ATTRIBUTE_EARTH)
end