local cm,m=GetID()
cm.name="极大炎融合"
function cm.initial_effect(c)
	--Activate
	local e1=RD.CreateFusionEffect(c,nil,cm.spfilter,nil,0,0,cm.matcheck,cm.move,nil,cm.operation)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
--Activate
cm.indval=RD.ValueEffectIndesType(0,TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
function cm.exfilter(c)
	return c:IsType(TYPE_MAXIMUM) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function cm.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
function cm.matcheck(tp,sg,fc)
	return sg:IsExists(cm.exfilter,1,nil)
end
function cm.move(tp,mat,e)
	if mat:IsExists(RD.IsMaximumMode,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return RD.FusionToGrave(tp,mat)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp,mat,fc)
	if e:GetLabel()==1 then
		RD.AttachEffectIndes(e,fc,cm.indval,aux.Stringid(m,1),RESET_EVENT+RESETS_STANDARD)
		RD.AttachPierce(e,fc,aux.Stringid(m,2),RESET_EVENT+RESETS_STANDARD)
	end
end