local cm,m=GetID()
local list={120294066}
cm.name="狮子的强袭"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsRace(RACE_BEAST)
end
function cm.spfilter(c)
	return c:IsCode(list[1])
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	RD.AttachAtkDef(e,rc,2000,0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,true)
end