local cm,m=GetID()
local list={120287031,120287032}
cm.name="双焰魔的祭坛"
function cm.initial_effect(c)
	RD.AddCodeList(c,list)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_EQUAL,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.matfilter(c)
	return c:IsRace(RACE_FIEND)
end
function cm.spfilter(c)
	return c:IsCode(list[1],list[2])
end
function cm.exfilter(c)
	return RD.IsPreviousMaximumMode(c)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	if mat:IsExists(cm.exfilter,1,nil) then
		RD.AttachAtkDef(e,rc,2000,2000,RESET_EVENT+RESETS_STANDARD,true)
		RD.AttachEffectIndes(e,rc,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD)
	end
end