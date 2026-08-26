local cm,m=GetID()
cm.name="力量结合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,nil,RD.FusionToGrave,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
function cm.spfilter(c)
	return c:IsRace(RACE_MACHINE)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	local atk=fc:GetAttack()
	RD.AttachAtkDef(e,fc,fc:GetBaseAttack(),0,RESET_EVENT+RESETS_STANDARD,true)
	local dam=math.max(0,fc:GetAttack()-atk)
	--Damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(dam)
	e1:SetOperation(cm.damop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
end