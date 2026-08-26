local cm,m=GetID()
cm.name="忍法 无敌变化之术"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateRitualEffect(c,RITUAL_ORIGINAL_LEVEL_GREATER,cm.matfilter,cm.spfilter,nil,0,0,nil,RD.RitualToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.matfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR)
end
function cm.spfilter(c)
	return c:IsLevel(8) and c:IsAttack(2500) and RD.IsDefense(c,1500)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,rc)
	RD.AttachBattleIndes(e,rc,1,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	RD.AttachEffectIndes(e,rc,cm.indval,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
end